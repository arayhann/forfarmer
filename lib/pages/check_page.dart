import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forfarmer/pages/camera_page.dart';

class CheckPage extends HookWidget {
  const CheckPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _activePage = useState<double>(0);
    final _pageViewController = usePageController(
      initialPage: 0,
    );

    useEffect(() {
      _pageViewController.addListener(() {
        if (_pageViewController.page != null) {
          _activePage.value = _pageViewController.page!;
        }
      });
      return;
    }, []);

    return Scaffold(
      backgroundColor: Color(0xFFF3F3F1),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              physics: BouncingScrollPhysics(),
              controller: _pageViewController,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Image.asset(
                          'assets/images/img-illustration-onboardhama-a.png',
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            'Cara Mudah Deteksi Hama',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            'Ketahui hama yang menjangkit tanaman anda menggunakan Deteksi Hama dengan langkah yang sangat mudah',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox.shrink(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Image.asset(
                          'assets/images/img-illustration-onboardhama-b.png',
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            'Foto dan Tunggu',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            'Foto atau unggah bagian dari tanaman anda yang terjangkit hama dengan fokus dan jelas. Unggah foto, lalu kami akan mengidentifikasi masalah tanaman Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox.shrink(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Image.asset(
                          'assets/images/img-illustration-onboardhama-c.png',
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            'Tindaklanjuti Hama',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            'Aplikasi  akan memberikan opsi pengobatan hama untuk ditindak lanjuti langkah selanjitnya oleh Anda',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8,
            child: ListView.separated(
              itemCount: 3,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => const SizedBox(
                width: 8,
              ),
              itemBuilder: (context, index) {
                return AnimatedOpacity(
                  opacity: index == _activePage.value ? 1 : 0.3,
                  duration: Duration(milliseconds: 300),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(0xFF72BF00),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraPage()),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                    (states) => Color(0xFF03755F),
                  ),
                  shape: MaterialStateProperty.resolveWith(
                    (states) => RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                child: Text(
                  'Deteksi Hama',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
