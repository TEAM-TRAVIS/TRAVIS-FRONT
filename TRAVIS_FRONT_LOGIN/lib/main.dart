import 'package:flutter/material.dart';
import 'package:myapp/utils.dart';
import 'package:myapp/pages/create_account.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

