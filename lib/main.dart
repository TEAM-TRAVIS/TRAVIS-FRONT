import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Travis/utils.dart';
import 'package:Travis/pages/CreateAccount.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized(); // 앱 초기화
	await Permission.location.request();
	runApp(const Travis());
}

class Travis extends StatelessWidget {
	const Travis({super.key});

	@override
	Widget build(BuildContext context) {
		SystemChrome.setPreferredOrientations([
			DeviceOrientation.portraitUp,
			DeviceOrientation.portraitDown,
		]);
		return MaterialApp(
			title: 'Travis',
			debugShowCheckedModeBanner: false,
			scrollBehavior: MyCustomScrollBehavior(),
			theme: ThemeData(
				primarySwatch: Colors.blue,
			),
			home: const Scaffold(
				body: SingleChildScrollView(
					child: CreateAccount(),
				),
			),
		);
	}
}
