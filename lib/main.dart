import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color.fromRGBO(95, 207, 128, 71), // สีหลักของแอป
        appBarTheme: AppBarTheme(
          toolbarHeight: 75,
          backgroundColor: Color.fromRGBO(95, 207, 128, 71), // สีของ App bar
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final Dio _dio = Dio();
  late Future<List<Map<String, dynamic>>> _herbsData;
  List<String> sicknessList = [];
  TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedCategory = 'ค้นหาด้วยชื่อ'; // ค่าเริ่มต้นของหมวดหมู่ที่เลือก
  List<String> _categories = [
    'ค้นหาด้วยชื่อ',
    'ค้นหาด้วยอาการ',
    'ค้นหาด้วยโรค'
  ];
  ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  int _currentPage = 1;
  final int _itemsPerPage = 15;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500), // ระยะเวลาของ animation
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut, // เลือก curve ตามที่ต้องการ
    );
    _herbsData = fetchData('data');
    _herbsData.then((data) {
      setState(() {
        _totalPages = (data.length / _itemsPerPage).ceil();
      });
    });
    fetchHerbsBySick();
  }

  List<Map<String, dynamic>> getPageData(List<Map<String, dynamic>> data) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    if (endIndex <= data.length) {
      return data.sublist(startIndex, endIndex);
    } else {
      return data.sublist(startIndex);
    }
  }

  Future<List<Map<String, dynamic>>> fetchData(String endpoint,
      {String? query}) async {
    try {
      String apiUrl =
          'https://1931-223-24-164-180.ngrok-free.app/api/$endpoint';
      Map<String, dynamic> queryParams = {'query': query};

      if (query == null || query.isEmpty) {
        apiUrl = 'https://1931-223-24-164-180.ngrok-free.app/api/data';
        queryParams = {};
      } else {
        switch (_selectedCategory) {
          case 'ค้นหาด้วยชื่อ':
            apiUrl =
            'https://1931-223-24-164-180.ngrok-free.app/api/n_search/$query';
            break;
          case 'ค้นหาด้วยอาการ':
            apiUrl =
            'https://1931-223-24-164-180.ngrok-free.app/api/a_search/$query';
            break;
          case 'ค้นหาด้วยโรค':
            apiUrl =
            'https://1931-223-24-164-180.ngrok-free.app/api/s_search/$query';
            break;
          default:
            apiUrl =
            'https://1931-223-24-164-180.ngrok-free.app/api/n_search/$query';
            break;
        }
        queryParams = {};
      }

      final response = await _dio.get(apiUrl, queryParameters: queryParams);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> responseData =
        List<Map<String, dynamic>>.from(response.data);

        if (responseData.isNotEmpty) {
          print('API useable');
          _totalPages = (responseData.length / _itemsPerPage).ceil();
          return responseData;
        } else {
          print('API Response Data is empty');
          return [];
        }
      } else {
        throw Exception('ไม่สามารถโหลดข้อมูลได้');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('ข้อผิดพลาด: $e');
    }
  }

  Future<List<String>> fetchCharmenu() async {
    try {
      final response = await Dio().get('https://1931-223-24-164-180.ngrok-free.app/api/charmenu');
      if (response.statusCode == 200) {
        List<dynamic> dataList = response.data;
        List<String> charList = dataList.map((item) {
          final map = item as Map<String, dynamic>;
          return map.values.first.toString();
        }).toList();
        return charList;
      } else {
        throw Exception('Failed to load charmenu');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> fetchHerbsBySickness(String sickness) async {
    try {
      final response = await _dio.get('https://1931-223-24-164-180.ngrok-free.app/api/s_category/$sickness');
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> responseData = List<Map<String, dynamic>>.from(response.data as List<dynamic>);
        setState(() {
          // อัพเดทข้อมูลสมุนไพรที่เกี่ยวข้องกับโรคที่เลือก
          _herbsData = Future.value(responseData);
          _totalPages = (responseData.length / _itemsPerPage).ceil();
        });
      } else {
        throw Exception('Failed to load herbs by sickness');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> fetchHerbsByFl(String firstletter) async {
    try {
      final response = await _dio.get('https://1931-223-24-164-180.ngrok-free.app/api/fl_category/$firstletter');
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> responseData = List<Map<String, dynamic>>.from(response.data as List<dynamic>);
        setState(() {
          // อัพเดทข้อมูลสมุนไพรที่เกี่ยวข้องกับโรคที่เลือก
          _herbsData = Future.value(responseData);
          _totalPages = (responseData.length / _itemsPerPage).ceil();
        });
      } else {
        throw Exception('Failed to load herbs by sickness');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> fetchHerbsBySick() async {
    try {
      final response = await _dio.get('https://1931-223-24-164-180.ngrok-free.app/api/smenu');
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(response.data as List<dynamic>);
        List<String> tempList = [];
        dataList.forEach((map) {
          if(map.containsKey('Sick')) {
            tempList.add(map['Sick']);
          }
        });
        setState(() {
          sicknessList = tempList;
        });
      } else {
        throw Exception('Failed to load herbs');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            title: Text(
              'Thai Herb App',
              style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PK Nakhon Sawan Demo'),
            ),
            elevation: 8.0,
            floating: true,
            snap: true,
            leading: IconButton(
              icon: Icon(Icons.menu),
              iconSize: 32,
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.only(bottom: 8, top: 8, left: 5),
                      child: Container(
                        alignment: Alignment.center,
                        height: 70.0,
                        width: 155,
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue!;
                              _currentPage =
                              1; // รีเซ็ตหน้าเมื่อมีการเปลี่ยน dropdown
                              _herbsData = fetchData(
                                newValue!.isEmpty ? 'data' : 'search',
                                query: _searchController.text,
                              );
                              _herbsData.then((data) {
                                setState(() {
                                  _totalPages =
                                      (data.length / _itemsPerPage).ceil();
                                });
                              });
                            });
                          },
                          items: _categories
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.black,
                                  fontFamily: 'PK Nakhon Sawan Demo',
                                ),
                              ),
                            );
                          }).toList(),
                          dropdownColor: Colors.white,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontFamily: 'PK Nakhon Sawan Demo',
                          ),
                          elevation: 2,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Container(
                        height: 70.0,
                        width: 220,
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            _herbsData = fetchData(
                                value.isEmpty ? 'data' : 'search',
                                query: value);
                            setState(() {
                              _herbsData.then((data) {
                                setState(() {
                                  _currentPage = 1;
                                  _totalPages =
                                      (data.length / _itemsPerPage).ceil();
                                });
                              });
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'ค้นหา',
                            labelStyle: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black54,
                              fontFamily: 'PK Nakhon Sawan Demo',
                            ),
                            hintText: 'ชื่อสมุนไพร,โรค,อาการ ',
                            hintStyle: TextStyle(
                              fontSize: 18.0,
                              color: Colors.black54,
                              fontFamily: 'PK Nakhon Sawan Demo',
                            ),
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          FutureBuilder(
            future: _herbsData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                  ),
                );
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              } else if (snapshot.data == null ||
                  (snapshot.data as List).isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('ไม่มีสมุนไพรที่ค้นหา',
                    style: TextStyle(
                      fontSize: 22.0,
                      color: Colors.black,
                      fontFamily: 'PK Nakhon Sawan Demo',
                    ),
                  )),
                );
              } else {
                final pageData =
                getPageData(snapshot.data as List<Map<String, dynamic>>);
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisExtent: 150,
                    crossAxisSpacing: 6.0,
                    mainAxisSpacing: 6.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final herb = pageData[index];
                      return HerbBox(
                        herbName: herb['herbName'],
                        herbPic: herb['herbPic'],
                        cName: herb['Cname'],
                        aName: herb['Aname'],
                        ability: herb['Ability'],
                        sick: herb['Sick'].join(', '),
                        onTap: () {
                          navigateToHerbDetailPage(context, herb['herbName']);
                        },
                      );
                    },
                    childCount: pageData.length,
                  ),
                );
              }
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(95, 207, 128, 71),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: Colors.black,
                    width: 6.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      if (_currentPage == 1)
                        SizedBox(
                          height: 50,
                          width: 50,
                        ),
                      if (_currentPage >
                          1) // ตรวจสอบว่าเราอยู่ที่หน้าแรกหรือไม่
                        IconButton(
                          icon: Image.asset('assets/left-arrow.png',
                              width: 50, height: 50),
                          onPressed: () {
                            setState(() {
                              _currentPage--;
                              _scrollController.animateTo(
                                0.0,
                                duration: Duration(milliseconds: 900),
                                curve: Curves.easeInOut,
                              );
                            });
                          },
                        ),
                      Expanded(
                        child: Text(
                          'หน้า $_currentPage / $_totalPages',
                          textAlign: TextAlign.center, // จัดตำแหน่งข้อความกลาง
                          style: TextStyle(
                            fontSize: 22.0,
                            color: Colors.black,
                            fontFamily: 'PK Nakhon Sawan Demo',
                          ),
                        ),
                      ),
                      if (_currentPage ==
                          _totalPages) // เพิ่มเงื่อนไขเพื่อให้ลูกศรปิดตัวเมื่ออยู่ที่หน้าสุดท้าย
                        SizedBox(width: 50.0), // ช่องว่างมีขนาดเท่ากับลูกศร
                      if (_currentPage <
                          _totalPages) // ตรวจสอบว่าเราอยู่ที่หน้าสุดท้ายหรือไม่
                        IconButton(
                          icon: Image.asset('assets/right-arrow.png',
                              width: 50, height: 50),
                          onPressed: () {
                            setState(() {
                              _currentPage++;
                              _scrollController.animateTo(
                                0.0,
                                duration: Duration(milliseconds: 900),
                                curve: Curves.easeInOut,
                              );
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image: AssetImage('assets/category-pic.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Text(
                  'หมวดหมู่',
                  style: TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'PK Nakhon Sawan Demo',
                  ),
                ),
              ),
              ExpansionTile(
                title: Text(
                  'ก-ฮ',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'PK Nakhon Sawan Demo',
                  ),
                ),
                children: <Widget>[
                  FutureBuilder<List<String>>(
                    future: fetchCharmenu(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            final char = snapshot.data![index];
                            return ListTile(
                              title: Text(
                                char,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'PK Nakhon Sawan Demo',
                                ),
                              ),
                              onTap: () {
                                _currentPage = 1;
                                fetchHerbsByFl(char);
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
              ExpansionTile(
                title: Text(
                  'โรค',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'PK Nakhon Sawan Demo',
                  ),
                ),
                children: <Widget>[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: sicknessList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(
                          sicknessList[index],
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'PK Nakhon Sawan Demo',
                          ),
                        ),
                        onTap: () {
                          _currentPage = 1;
                          fetchHerbsBySickness(sicknessList[index]);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HerbBox extends StatefulWidget {
  final String herbName;
  final String cName;
  final String aName;
  final String ability;
  final String sick;
  final String herbPic;
  final VoidCallback onTap;

  HerbBox({
    required this.herbName,
    required this.herbPic,
    required this.cName,
    required this.aName,
    required this.ability,
    required this.sick,
    required this.onTap,
  });

  @override
  _HerbBoxState createState() => _HerbBoxState();
}

class _HerbBoxState extends State<HerbBox> with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.translate(
            offset: Offset(50.0 * (1.0 - _animation.value), 0.0),
            child: InkWell(
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
                child: Container(
                  width: 0.0,
                  height: 0.0,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(248, 243, 217, 90),
                    border: Border.all(color: Color.fromRGBO(46, 92, 30, 90), width: 4.0),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12, top: 12, right: 1.0, bottom: 12),
                        child: Container(
                          height: 120.0,
                          width: 150.0,
                          decoration: BoxDecoration(
                            border:
                            Border.all(color: Color.fromRGBO(46, 92, 30,100 ), width: 2.0),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              child: Image.asset(
                                'assets/${widget.herbPic}',
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.herbName,
                                style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'PK Nakhon Sawan Demo'),
                              ),
                              Text(
                                'ชื่อสามัญ: ${widget.cName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PK Nakhon Sawan Demo'),
                              ),
                              Text(
                                'ชื่อท้องถิ่น: ${widget.aName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PK Nakhon Sawan Demo'),
                              ),
                              Text(
                                'สรรพคุณ: ${widget.ability}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PK Nakhon Sawan Demo'),
                              ),
                              Text(
                                'รักษา: ${widget.sick}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PK Nakhon Sawan Demo'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HerbDetailPage extends StatefulWidget {
  final String herbName;

  HerbDetailPage({required this.herbName});

  @override
  _HerbDetailPageState createState() => _HerbDetailPageState();
}

class _HerbDetailPageState extends State<HerbDetailPage> {
  late Future<List<Map<String, dynamic>>> _herbDetailData;

  Future<List<Map<String, dynamic>>> fetchData() async {
    try {
      String apiUrl =
          'https://1931-223-24-164-180.ngrok-free.app/api/detail/${widget.herbName}';

      final response = await Dio().get(apiUrl);

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> responseData =
        List<Map<String, dynamic>>.from(response.data);

        if (responseData.isNotEmpty) {
          print('API Response Data: $responseData');
          return responseData;
        } else {
          print('API Response Data is empty');
          return [];
        }
      } else {
        throw Exception('ไม่สามารถโหลดข้อมูลได้');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('ข้อผิดพลาด: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _herbDetailData = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text(
              widget.herbName,
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'PK Nakhon Sawan Demo',
              ),
            ),
            floating: true,
            snap: true,
          ),
          SliverToBoxAdapter(
            child: FutureBuilder(
              future: fetchData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.connectionState == ConnectionState.done) {
                  print('Data from API: ${snapshot.data}');
                  if (snapshot.data == null ||
                      (snapshot.data as List).isEmpty) {
                    return Center(
                        child:
                        Text('No details found for ${widget.herbName}.'));
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: 20, left: 15, right: 15),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics:
                        ClampingScrollPhysics(), // เพิ่ม physics ให้กับ ListView เพื่อให้สามารถเลื่อนได้
                        itemCount: (snapshot.data as List).length,
                        itemBuilder: (context, index) {
                          final detail = (snapshot.data as List)[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color.fromRGBO(46, 92, 30,100 ), width: 8.0),
                                    borderRadius: BorderRadius.circular(12.0),
                                    color: Color(0xFFFFF7E6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  constraints: BoxConstraints(maxWidth: 400.0),
                                  child: Image.asset(
                                    'assets/${detail['herbPic']}',
                                    height: 250.0,
                                    width: double.maxFinite,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.0),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F6D5),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                    bottomLeft: Radius.circular(30.0),
                                    bottomRight: Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ชื่อสามัญ',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'PK Nakhon Sawan Demo',
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      '${detail['cName']}',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'PK Nakhon Sawan Demo'),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24.0),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F6D5),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                    bottomLeft: Radius.circular(30.0),
                                    bottomRight: Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ชื่อท้องถิ่น',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'PK Nakhon Sawan Demo',
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      '${detail['Aname']}',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'PK Nakhon Sawan Demo'),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24.0),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F6D5),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                    bottomLeft: Radius.circular(30.0),
                                    bottomRight: Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ชื่อวิทยาศาสตร์',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'PK Nakhon Sawan Demo',
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      '${detail['Sname']}',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'PK Nakhon Sawan Demo'),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24.0),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F6D5),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                    bottomLeft: Radius.circular(30.0),
                                    bottomRight: Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ลักษณะ',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'PK Nakhon Sawan Demo',
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      '${detail['herbDes']}',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'PK Nakhon Sawan Demo'),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24.0),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F6D5),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                    bottomLeft: Radius.circular(30.0),
                                    bottomRight: Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'สรรพคุณ',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'PK Nakhon Sawan Demo',
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      '${detail['Ability']}',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'PK Nakhon Sawan Demo'),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24.0),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F6D5),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                    bottomLeft: Radius.circular(30.0),
                                    bottomRight: Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'วิธีการใช้',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'PK Nakhon Sawan Demo',
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      '${detail['Method']}',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'PK Nakhon Sawan Demo'),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24.0),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F6D5),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                    bottomLeft: Radius.circular(30.0),
                                    bottomRight: Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'รักษา',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'PK Nakhon Sawan Demo',
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      '${detail['Sick'].join(', ')}',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'PK Nakhon Sawan Demo'),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24.0),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F6D5),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                    bottomLeft: Radius.circular(30.0),
                                    bottomRight: Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ข้อควรระวัง' + '*',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'PK Nakhon Sawan Demo',
                                        color: Colors.red,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      '${detail['Caution']}',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'PK Nakhon Sawan Demo'),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24.0),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFE8F6D5),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                    bottomLeft: Radius.circular(30.0),
                                    bottomRight: Radius.circular(10.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'อ้างอิง',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'PK Nakhon Sawan Demo',
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      '${detail['Ref']}',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'PK Nakhon Sawan Demo'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  }
                } else {
                  return Text(
                      'Unhandled ConnectionState: ${snapshot.connectionState}');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

void navigateToHerbDetailPage(BuildContext context, String herbName) {
  Navigator.of(context).push(PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: Container(
          color: Colors.greenAccent, // เปลี่ยนสีพื้นหลังของหน้าจอเป็นสีขาว
          child: HerbDetailPage(herbName: herbName),
        ),
      );
    },
  ));
}
