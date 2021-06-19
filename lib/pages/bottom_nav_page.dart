import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forfarmer/pages/check_page.dart';
import 'package:forfarmer/pages/home_page.dart';

class BottomNavPage extends HookWidget {
  const BottomNavPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _selectedIndex = useState<int>(0);

    final _onItemTapped = useMemoized(
      () => (int index) {
        _selectedIndex.value = index;
      },
      [],
    );

    final List<Widget> _pages = <Widget>[
      HomePage(),
      CheckPage(),
    ];

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        notchMargin: 12,
        child: Container(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () => _onItemTapped(0),
                borderRadius: BorderRadius.circular(30),
                child: Tooltip(
                  message: 'Beranda',
                  child: Container(
                    width: 60,
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.grey,
                            _selectedIndex.value == 0
                                ? BlendMode.dst
                                : BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            'assets/images/ic-menu-home.png',
                            width: 24,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Beranda',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: _selectedIndex.value == 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: _selectedIndex.value == 0
                                ? Color(0xFF03755F)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => _onItemTapped(1),
                borderRadius: BorderRadius.circular(30),
                child: Tooltip(
                  message: 'Profilku',
                  child: Container(
                    width: 60,
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.grey,
                            _selectedIndex.value == 1
                                ? BlendMode.dst
                                : BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            'assets/images/ic-menu-check.png',
                            width: 24,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Periksa',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: _selectedIndex.value == 1
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: _selectedIndex.value == 1
                                ? Color(0xFF03755F)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex.value],
    );
  }
}
