import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:stadium_food/src/bloc/stadium/stadium_bloc.dart';
import 'package:stadium_food/src/bloc/theme/theme_bloc.dart';
import 'package:stadium_food/src/core/config/app_config.dart';
import 'package:stadium_food/src/core/config/stadium_geo.dart';
import 'package:stadium_food/src/core/config/stadium_theme.dart';
import 'package:stadium_food/src/core/translations/translate.dart';
import 'package:stadium_food/src/data/models/stadium.dart';
import 'package:stadium_food/src/presentation/utils/app_colors.dart';
import 'package:stadium_food/src/presentation/widgets/stadium_shimmer.dart';
import 'package:stadium_food/src/services/location_service.dart';

/// Matches web StadiumSelectionScreen:
/// - new users: auto-locate nearest venue (≤200km) and auto-continue after ~900ms
/// - returning users changing venue: suggest nearest but do not auto-continue
class SelectStadiumScreen extends StatefulWidget {
  const SelectStadiumScreen({super.key});

  @override
  State<SelectStadiumScreen> createState() => _SelectStadiumScreenState();
}

class _SelectStadiumScreenState extends State<SelectStadiumScreen> {
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();

  bool _isNewUserFlow = true;
  bool _didAutoLocate = false;
  bool _locating = false;
  bool _autoContinuing = false;
  String _locationStatus = '';
  String _locationStatusType = ''; // info | success | error
  String? _nearestId;
  Stadium? _highlighted;

  @override
  void initState() {
    super.initState();
    final saved = Hive.box('myBox').get('selectedStadium');
    _isNewUserFlow = saved is! Map || (saved['id']?.toString().isEmpty ?? true);
    context.read<StadiumBloc>().add(LoadStadiums());
  }

  Future<void> _saveSelectedStadium(Stadium stadium) async {
    if (_autoContinuing) return;
    _autoContinuing = true;

    context.read<StadiumBloc>().add(SelectStadium(stadium));

    final themeData = StadiumTheme.fromStadium(stadium).apply();
    if (mounted) {
      context.read<ThemeBloc>().add(ChangeTheme(themeData: themeData));
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<void> _requestNearestVenue(
    List<Stadium> stadiums, {
    required bool autoContinue,
  }) async {
    if (!mounted) return;
    setState(() {
      _locating = true;
      _locationStatusType = 'info';
      _locationStatus = 'Finding nearest venue…';
    });

    try {
      final position = await _locationService.getCurrentLocation();
      final anyWithCoords =
          stadiums.any((s) => StadiumGeo.coordsOf(s) != null);
      if (!anyWithCoords) {
        if (!mounted) return;
        setState(() {
          _nearestId = null;
          _locationStatusType = 'error';
          _locationStatus =
              'Venues have no coordinates. Please select manually.';
        });
        return;
      }

      final nearest = StadiumGeo.findNearest(
        stadiums,
        position.latitude,
        position.longitude,
      );

      if (nearest == null) {
        // Admin test mode: fall back to first venue so simulators can proceed
        if (AppConfig.useTestApis && stadiums.isNotEmpty && autoContinue) {
          if (!mounted) return;
          setState(() {
            _nearestId = stadiums.first.id;
            _highlighted = stadiums.first;
            _locationStatusType = 'success';
            _locationStatus =
                'Test mode: no venue nearby — selecting ${stadiums.first.name}';
          });
          await Future.delayed(const Duration(milliseconds: 900));
          if (!mounted || _autoContinuing) return;
          await _saveSelectedStadium(stadiums.first);
          return;
        }
        if (!mounted) return;
        setState(() {
          _nearestId = null;
          _highlighted = null;
          _locationStatusType = 'error';
          _locationStatus =
              'No venue nearby (within ${StadiumGeo.nearestVenueMaxKm.round()} km). '
              'Please select a venue manually.';
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _nearestId = nearest.stadium.id;
        _highlighted = nearest.stadium;
        _locationStatusType = 'success';
        _locationStatus =
            'Nearest: ${nearest.stadium.name} (${StadiumGeo.formatDistanceKm(nearest.distanceKm)} away)';
      });

      if (autoContinue) {
        await Future.delayed(const Duration(milliseconds: 900));
        if (!mounted || _autoContinuing) return;
        // User may have tapped another card meanwhile
        if (_highlighted?.id == nearest.stadium.id) {
          await _saveSelectedStadium(nearest.stadium);
        }
      }
    } catch (e) {
      if (!mounted) return;
      // Admin test mode: location often unavailable on simulators
      if (AppConfig.useTestApis && stadiums.isNotEmpty && autoContinue) {
        setState(() {
          _nearestId = stadiums.first.id;
          _highlighted = stadiums.first;
          _locationStatusType = 'success';
          _locationStatus =
              'Test mode: location unavailable — selecting ${stadiums.first.name}';
        });
        await Future.delayed(const Duration(milliseconds: 900));
        if (!mounted || _autoContinuing) return;
        await _saveSelectedStadium(stadiums.first);
        return;
      }
      final msg = e.toString().toLowerCase();
      setState(() {
        _locationStatusType = 'error';
        if (msg.contains('denied')) {
          _locationStatus =
              'Location permission denied. Please select a venue manually.';
        } else if (msg.contains('disabled')) {
          _locationStatus =
              'Location services are off. Please select a venue manually.';
        } else {
          _locationStatus =
              'Location unavailable. Please select a venue manually.';
        }
      });
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _onStadiumsLoaded(List<Stadium> stadiums) {
    if (_didAutoLocate || stadiums.isEmpty) return;
    _didAutoLocate = true;
    // Same as web: auto-continue only for new users
    _requestNearestVenue(stadiums, autoContinue: _isNewUserFlow);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildLocationBar(),
            _buildSearchBar(),
            Expanded(child: _buildStadiumList()),
            if (_highlighted != null && !_isNewUserFlow)
              _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            Translate.get('select_stadium_title'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            _isNewUserFlow
                ? 'We\'ll pick the nearest venue for you'
                : 'Choose a venue to continue',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBar() {
    if (_locationStatus.isEmpty && !_locating) {
      return const SizedBox.shrink();
    }
    Color bg;
    Color fg;
    switch (_locationStatusType) {
      case 'success':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF065F46);
        break;
      case 'error':
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFF991B1B);
        break;
      default:
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF1E40AF);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (_locating)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: fg),
            )
          else
            Icon(
              _locationStatusType == 'success'
                  ? Icons.my_location
                  : Icons.info_outline,
              size: 18,
              color: fg,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _locating ? 'Finding nearest venue…' : _locationStatus,
              style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () {
              final state = context.read<StadiumBloc>().state;
              if (state is StadiumsLoaded) {
                _requestNearestVenue(state.stadiums, autoContinue: false);
              }
            },
            child: Text('Retry', style: TextStyle(color: fg, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          if (query.isEmpty) {
            context.read<StadiumBloc>().add(LoadStadiums());
          } else {
            context.read<StadiumBloc>().add(SearchStadiums(query));
          }
        },
        decoration: InputDecoration(
          hintText: Translate.get('select_stadium_search'),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _highlighted == null
                ? null
                : () => _saveSelectedStadium(_highlighted!),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Continue with ${_highlighted!.name}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStadiumList() {
    return BlocConsumer<StadiumBloc, StadiumState>(
      listener: (context, state) {
        if (state is StadiumsLoaded) {
          _onStadiumsLoaded(state.stadiums);
        }
      },
      builder: (context, state) {
        if (state is StadiumsLoading) {
          return const StadiumShimmer();
        }

        if (state is StadiumError) {
          return Center(
            child: Text(
              Translate.get('select_stadium_error')
                  .replaceAll('{0}', state.message),
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is StadiumsLoaded) {
          if (state.stadiums.isEmpty) {
            return Center(
              child: Text(Translate.get('select_stadium_empty')),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: state.stadiums.length,
            itemBuilder: (context, index) {
              final stadium = state.stadiums[index];
              return _buildStadiumCard(stadium);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStadiumCard(Stadium stadium) {
    final isNearest = stadium.id == _nearestId;
    final isSelected = stadium.id == _highlighted?.id;

    return GestureDetector(
      onTap: () {
        // Manual tap cancels auto-continue path by selecting immediately
        setState(() => _highlighted = stadium);
        _saveSelectedStadium(stadium);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected || isNearest
                ? AppColors.primaryColor
                : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.network(
                stadium.imageUrl.isNotEmpty
                    ? stadium.imageUrl
                    : (stadium.bannerUrl),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child:
                        const Icon(Icons.stadium, size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
            if (isNearest)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Nearest',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stadium.brandName.isNotEmpty
                          ? stadium.brandName
                          : stadium.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      stadium.location,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
