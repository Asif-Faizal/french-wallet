import 'dart:ui';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ViewChildCardScreen extends StatefulWidget {
  const ViewChildCardScreen({super.key});

  @override
  State<ViewChildCardScreen> createState() => _ViewChildCardScreenState();
}

class _ViewChildCardScreenState extends State<ViewChildCardScreen> {
  final List<int> _cardList = List.generate(5, (index) => index);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: NormalAppBar(text: ''),
      body: ListView.builder(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(20),
        itemCount: _cardList.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ChildCard(size: size),
              Divider(
                color: Colors.amber.shade300,
                thickness: 1,
              ),
            ],
          );
        },
      ),
    );
  }
}

class ChildCard extends StatefulWidget {
  final Size size;
  const ChildCard({required this.size, Key? key}) : super(key: key);

  @override
  _ChildCardState createState() => _ChildCardState();
}

class _ChildCardState extends State<ChildCard>
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
      setState(() {
        _isFront = !_isFront;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size.height / 3 - widget.size.height / 100,
      child: Column(
        children: [
          SizedBox(
            height: widget.size.height / 80,
          ),
          Transform(
            transform: Matrix4.rotationY(_animation.value * math.pi),
            alignment: Alignment.center,
            child: _animation.value < 0.5
                ? _buildFront(widget.size)
                : Transform(
                    transform: Matrix4.rotationY(math.pi),
                    alignment: Alignment.center,
                    child: _buildBack(widget.size),
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _flipCard,
                child: Icon(Icons.rotate_90_degrees_ccw,
                    color: Colors.amber.shade900),
              ),
              TextButton(
                onPressed: () {},
                child: Icon(Icons.visibility_off_outlined,
                    color: Colors.amber.shade900),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFront(Size size) {
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
                          Text('VISA',
                              style: TextStyle(
                                  fontSize: size.height / 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Icon(
                            Icons.wallet,
                            size: size.height / 15,
                            color: Colors.white,
                          )
                        ],
                      ),
                      SizedBox(
                        width: size.width / 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Balance:',
                                style: TextStyle(
                                    fontSize: size.height / 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(
                              width: size.width / 40,
                            ),
                            Text('**********',
                                style: TextStyle(
                                    fontSize: size.height / 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1234 **** **** 1234',
                              style: TextStyle(
                                  fontSize: size.height / 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Column(
                            children: [
                              Text('Valid Thru',
                                  style: TextStyle(
                                      fontSize: size.height / 60,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              Text('09/30',
                                  style: TextStyle(
                                      fontSize: size.height / 50,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: size.height / 60,
                      ),
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
                  height: size.height / 6,
                  width: double.infinity,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.2, sigmaY: 0.2),
                    child: Container(
                      height: size.height / 4.2,
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.height / 60,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: size.height / 25,
                                width: size.width / 1.6,
                                color: Colors.grey.shade300,
                                margin: const EdgeInsets.symmetric(vertical: 7),
                              ),
                              Container(
                                height: size.height / 25,
                                width: size.width / 10,
                                color: Colors.white,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('***',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: size.height / 20,
                  color: Colors.black,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
