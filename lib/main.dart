import 'package:flutter/material.dart';
import 'package:drupal_linkset_menu/drupal_linkset_menu.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dupal Linkset Menu Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drupal Menu Example"),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Menu>(
                future: getMenu("main"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return SingleChildScrollView(
                    child: Container(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('Main Menu',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade400)),
                            ),
                            ...buildMenu(snapshot.data.tree ?? []),
                          ]),
                    ),
                  );
                },
              ),
            ),
            FutureBuilder<Menu>(
              future: getMenu("footer"),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                return SingleChildScrollView(
                  child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ...buildMenu(snapshot.data.tree ?? []),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Footer Menu',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade400)),
                          ),
                        ]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildMenu(List<MenuElement> elements) {
    var widgets = elements.map((e) => buildMenuItem(e)).toList();
    return widgets;
  }

  Widget buildMenuItem(MenuElement e) {
    String title = e.title;
    String href = e.href;
    List<MenuElement> children = e.children;

    if (children.length >= 1) {
      return ExpansionTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        ),
        children: <Widget>[...buildMenu(children)],
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () async {
            await launch(href, webOnlyWindowName: "_self");
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade400),
            ),
          ),
        ),
      );
    }
  }

  Future<Menu> getMenu(String menu) {
    String apiURL = 'http://localhost:50915/system/menu/${menu}/linkset';
    return getDrupalMenuFromURL(apiURL, menu);
  }
}
