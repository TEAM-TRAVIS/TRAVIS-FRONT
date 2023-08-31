import 'dart:convert';

import 'package:Travis/pages/MyPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Travis/utils.dart';
import 'package:http/http.dart' as http;

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false; // 로딩 상태 확인
  int pageCount = 1;
  int numberOfFeed = 3;
  List<dynamic> feedItems = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    getAllPublicSummary();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      getAllPublicSummary();
    }
  }

  Future getAllPublicSummary() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      var response = await http.get(Uri.parse(
          "http://44.218.14.132/feed?page=$pageCount&limit=$numberOfFeed")); //get
      print(response.statusCode);
      var data = jsonDecode(response.body);
      setState(() {
        feedItems.addAll(data['summaries']);
        pageCount++;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Feed",
            style: SafeGoogleFont(
              'MuseoModerno',
              fontSize: 21,
              color: const Color.fromARGB(255, 236, 246, 255),
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 41, 91, 242),
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                feedItems.clear();
              },
              child: Text(
                "refresh",
              ),
            ),
            TextButton(
                onPressed: () {
                  // getAllPublicSummary();
                  // print(feedItems);
                  // print(feedItems.length);
                },
                child: Text("test"),
                ),
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => MyPage()));
              },
            )
          ],
        ),
        body: _postsListView(context),
      ),
    );
  }

  Widget _postsListView(BuildContext context) {
    return ListView.builder(
        controller: _scrollController,
        itemCount: feedItems.length + 1,
      itemBuilder: (context, index) {
        if (index < feedItems.length) {
          return _postView(context, index);
        } else if (_isLoading) {
          return Center(child: CircularProgressIndicator());
        } else {
          return SizedBox.shrink();
        }
      }
    );
  }

  Widget _postView(BuildContext context, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _postAuthorRow(context, index),
        _postImage(context, index),
        SizedBox(height: 5),
        _postCaption(context, index),
        _postCommentsButton(context),
        SizedBox(height: 20),
      ],
    );
  }

  /// 유저 프로필 이미지 및 유저 이름 -> 이곳을 누르면 해당 유저 프로필로 넘어가야함.
  Widget _postAuthorRow(BuildContext context, int index) {
    const double avatarDiameter = 44;
    return GestureDetector(
      // onTap: () => BlocProvider.of<HomeNavigatorCubit>(context).showProfile(),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: avatarDiameter,
              height: avatarDiameter,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(avatarDiameter / 2),
                child: CachedNetworkImage(
                  imageUrl:
                      "https://i.pinimg.com/originals/65/af/17/65af17e3745c1a5250a4614f31eb0d02.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Text(
            'Haerin',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          )
        ],
      ),
    );
  }

  /// 게시물의 사진 -> 우리에게는 경로 캡쳐 이미지
  Widget _postImage(BuildContext context, int index) {
    return AspectRatio(
      aspectRatio: 1,
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl:
            'https://news.koreadaily.com/data/photo/2023/08/04/9f2025fe-1819-42a3-b5c1-13032da70bc8.jpg',
      ),
    );
  }

  /// 게시물의 텍스트
  Widget _postCaption(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            feedItems[index]['title'],
            style: SafeGoogleFont(
              'NanumGothic',
              fontWeight: FontWeight.bold
            ),
          ),
          Text(
            feedItems[index]['content'],
            style: SafeGoogleFont(
              'NanumGothic',
            ),
          ),
        ],
      ),
    );
  }

  /// 게시물 댓글 볼 수 있는 버튼
  Widget _postCommentsButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () =>
            // BlocProvider.of<HomeNavigatorCubit>(context).showComments(),
            print("hi"),
        child: Text(
          'View Comments',
          style: TextStyle(fontWeight: FontWeight.w200),
        ),
      ),
    );
  }
}
