import 'dart:ui';
import 'dart:math' as math;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class RetailHomeScreen extends StatefulWidget {
  const RetailHomeScreen({super.key});

  @override
  State<RetailHomeScreen> createState() => _RetailHomeScreenState();
}

class _RetailHomeScreenState extends State<RetailHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.status != AnimationStatus.forward) {
      if (_isFront) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      _isFront = !_isFront;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform(
              transform: Matrix4.rotationY(_animation.value * math.pi),
              alignment: Alignment.center,
              child: _animation.value < 0.5
                  ? _buildFront(size)
                  : Transform(
                      transform: Matrix4.rotationY(math.pi),
                      alignment: Alignment.center,
                      child: _buildBack(size),
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _flipCard,
                  child: Row(
                    children: [
                      Text(
                        'Flip card',
                        style: theme.textTheme.bodyMedium,
                      ),
                      SizedBox(
                        width: size.width / 40,
                      ),
                      Icon(Icons.keyboard_double_arrow_right_rounded)
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: size.height / 7,
              width: size.height,
              child: Center(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    buildListItem(
                      'Send',
                      Card(color: Colors.amber,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: IconButton(
                            icon: Icon(
                              Icons.send_outlined,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                      size,
                    ),
                    buildListItem(
                      'Receive',
                      Card(color: Colors.amber,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: IconButton(
                            icon: Icon(
                              Icons.download_outlined,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                      size,
                    ),
                    buildListItem(
                      'Top Up',
                      Card(color: Colors.amber,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: IconButton(
                            icon: Icon(
                              Icons.upload_file_outlined,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                      size,
                    ),
                    buildListItem(
                      'Card',
                      Card(color: Colors.amber,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: IconButton(
                            icon: Icon(
                              Icons.payment_outlined,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                      size,
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Service List', style: theme.textTheme.bodyMedium),
                TextButton(
                  onPressed: () {},
                  child: Text('View all'),
                ),
              ],
            ),
            SizedBox(
              height: size.height / 6,
              child: Center(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  scrollDirection: Axis.horizontal,
                  children: [
                    buildServiceListItem(
                      'International Recharge',
                      IconButton(
                        icon: Icon(
                          Icons.abc,
                        ),
                        onPressed: () {},
                      ),
                      size,
                    ),
                    buildServiceListItem(
                      'Playstation',
                      IconButton(
                        icon: Icon(
                          Icons.abc,
                        ),
                        onPressed: () {},
                      ),
                      size,
                    ),
                    buildServiceListItem(
                      'X Box',
                      IconButton(
                        icon: Icon(
                          Icons.abc,
                        ),
                        onPressed: () {},
                      ),
                      size,
                    ),
                    buildServiceListItem(
                      'Alfa',
                      IconButton(
                        icon: Icon(
                          Icons.abc,
                        ),
                        onPressed: () {},
                      ),
                      size,
                    ),
                    buildServiceListItem(
                      'Pay',
                      IconButton(
                        icon: Icon(
                          Icons.abc,
                        ),
                        onPressed: () {},
                      ),
                      size,
                    ),
                  ],
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  children: [
                    CarouselSlider(
                      items: [
                        'lib/assets/card.jpg',
                        'lib/assets/card.jpg',
                        'lib/assets/card.jpg',
                        'lib/assets/card.jpg',
                      ]
                          .map((item) => SizedBox(
                              height: size.height / 5,
                              width: double.infinity,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.asset(item, fit: BoxFit.cover))))
                          .toList(),
                      options: CarouselOptions(
                        height: size.height / 4,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 1.0,
                        aspectRatio: 2.0,
                        onPageChanged: (index, reason) {},
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [0, 1, 2, 3].map((index) {
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin:
                              const EdgeInsets.only(top: 10, right: 3, left: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
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

  Widget _buildFront(Size size) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            SizedBox(
              height: size.height / 4.2,
              width: double.infinity,
              child: Image.network(
                'https://img.freepik.com/premium-photo/abstract-amber-color-background-wallpaper-with-random-patterns-waves-curves_989263-7059.jpg',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: size.height / 4.2,
              width: double.infinity,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0.2, sigmaY: 0.2),
                child: Container(
                  height: size.height / 4,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.3),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('VISA', style: TextStyle(fontSize: size.height/25,fontWeight: FontWeight.bold,color: Colors.white)),
                          Icon(
                            Icons.wallet,
                            size: size.height / 15,
                            color: Colors.white,
                          )
                        ],
                      ),
                      SizedBox(width: size.width/2,
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text('Balance:',
                              style: TextStyle(fontSize: size.height/40,fontWeight: FontWeight.bold,color: Colors.white)),

                            Text('*****',
                                style: TextStyle(fontSize: size.height/40,fontWeight: FontWeight.bold,color: Colors.white)),
                            Icon(Icons.visibility,color: Colors.white),
                          ],
                        ),
                      ),Spacer(),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1234 4567 7890 1234',
                              style: TextStyle(fontSize: size.height/40,fontWeight: FontWeight.bold,color: Colors.white)),
                          Column(
                            children: [Text('Valid Thru', style: TextStyle(fontSize: size.height/60,fontWeight: FontWeight.bold,color: Colors.white)),
                              Text('09/30', style: TextStyle(fontSize: size.height/50,fontWeight: FontWeight.bold,color: Colors.white)),],
                          )
                        ],
                      ),
SizedBox(height: size.height/60,),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack(Size size) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          children: [
            SizedBox(
              height: size.height / 4.2,
              width: double.infinity,
              child: Image.network(
                'https://img.freepik.com/premium-photo/abstract-amber-color-background-wallpaper-with-random-patterns-waves-curves_989263-7059.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: size.height / 4.2,
                  width: double.infinity,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.2, sigmaY: 0.2),
                    child: Container(
                      height: size.height / 4.2,
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.3),
                      padding:
                          const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: size.height/60,),
                          Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: size.height / 25,

                                width: size.width/1.6,
                                color: Colors.grey.shade300,
                                margin: const EdgeInsets.symmetric(vertical: 7),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),

                                ),
                              ),Container(
                                height: size.height / 25,

                                width: size.width/8,
                                color: Colors.white,
                                margin: const EdgeInsets.symmetric(vertical: 7),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                child: Text('123',style:TextStyle(fontStyle: FontStyle.italic)),
                                ),
                              ),
                            ],
                          ),
                          Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.', style: TextStyle(fontSize: 11,color: Colors.white)),

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListItem(String text, Widget icon, Size size) {
    final theme = Theme.of(context);
    return Container(
      width: size.width / 5,
      margin:  EdgeInsets.symmetric(horizontal: size.width/60),
      
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          SizedBox(
            height: size.height / 70,
          ),
          Text(text, style: theme.textTheme.bodyMedium)
        ],
      ),
    );
  }

  Widget buildServiceListItem(String text, Widget icon, Size size) {
    final theme = Theme.of(context);
    return Container(
      width: size.width / 2.5,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            icon,
            SizedBox(
              height: size.height / 70,
            ),
            Text(text, style: theme.textTheme.bodyMedium)
          ],
        ),
      ),
    );
  }
}
