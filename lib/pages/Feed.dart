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
  static int page = 1;
  static int limit = 7;
  String getAllPublicSummaryUrl = "localhost:3000/feed?page=$page&limit=$limit";
  List<dynamic> feedItems = [];

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

      try {
        var response = await http.get(Uri.parse(getAllPublicSummaryUrl)); //post

        print(response.statusCode);
        print(response.body);

        if (response.statusCode == 201) {
          print("legend");
        }
      } catch (e) {
        debugPrint('오류 발생: $e');
      }

      setState(() {
        feedItems.addAll(
            List.generate(10, (index) => '추가된 항목 ${index + 1}'));
        page++;
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
            "Record",
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
                onPressed: () {getAllPublicSummary();},
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
      itemCount: 3,
      itemBuilder: (context, index) {
        return _postView(context);
      }
    );
  }

  Widget _postView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _postAuthorRow(context),
        _postImage(),
        SizedBox(
          height: 5,
        ),
        _postCaption(),
        _postCommentsButton(context),
        SizedBox(
          height: 20,
        )
      ],
    );
  }

  /// 유저 프로필 이미지 및 유저 이름 -> 이곳을 누르면 해당 유저 프로필로 넘어가야함.
  Widget _postAuthorRow(BuildContext context) {
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
  Widget _postImage() {
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
  Widget _postCaption() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'title',
            style: SafeGoogleFont(
              'NanumGothic',
              fontWeight: FontWeight.bold
            ),
          ),
          Text(
            'content',
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
