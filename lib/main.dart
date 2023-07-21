import 'package:flutter/material.dart';
import 'package:myapp/utils.dart';
import 'package:myapp/pages/CreateAccount.dart';

void main() => runApp(const Travis());

class Travis extends StatelessWidget {
  const Travis({super.key});

	@override
	Widget build(BuildContext context) {
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

// 테스트! !!

