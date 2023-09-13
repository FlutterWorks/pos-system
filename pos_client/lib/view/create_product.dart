import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pos/model/goods.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/model/goods_group.dart';

class CreateProduct extends StatefulWidget {
  const CreateProduct({super.key});

  @override
  State<CreateProduct> createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  GoodsProvider goodsProvider = GoodsProvider();
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    goodsProvider.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Product'),
      ),
      body: Center(
        child: Row(
          children: [
            Expanded(flex: 2, child: showPeoduct()),
          ],
        ),
      ),
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                                   Widget                                   */
  /* -------------------------------------------------------------------------- */
  Widget inputWidget(int groupId) {
    Good good = Good(groupId, '', 0);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Product Name',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: priceController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Product Price',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (image != null) {
                good.image = await image.readAsBytes();
              }
            },
            child: const Text('選擇產品圖片'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              good.groupId = groupId;
              good.name = nameController.text;
              good.price = double.parse(priceController.text);
              goodsProvider.insert(good);
              good.image = null;
              nameController.clear();
              priceController.clear();
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('新增產品'),
          ),
        ),
      ],
    );
  }

  Widget product(int groupId) {
    return FutureBuilder(
      initialData: const [],
      future: goodsProvider.getItemsByGroupId(groupId),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          List<Widget> widgets = [];
          for (Good item in snapshot.data ?? []) {
            widgets.add(item.toWidget(
              onTap: () => editproduct(item),
            ));
          }
          return Column(children: widgets);
        } else {
          return const Text('no data');
        }
      },
    );
  }

  Widget showPeoduct() {
    return FutureBuilder(
      future: GoodsGroupProvider().getAll(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        List<Widget> widgets = [];
        if (snapshot.hasData) {
          for (GoodsGroupItem item in snapshot.data!) {
            widgets.add(Column(
              children: [
                groubBar(item.name, () => addProduct(item)),
                product(item.id!),
              ],
            ));
          }
        }
        return ListView(
          children: [
            ...widgets,
            groubBar('新增群組', addGroup),
          ],
        );
      },
    );
  }

  Widget groubBar(String title, Function? onTap) {
    return Card(
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(10),
          child: Text(title),
        ),
      ),
    );
  }

  /* -------------------------------------------------------------------------- */
  /*                                  Function                                  */
  /* -------------------------------------------------------------------------- */
  void addGroup() {
    Uint8List? image;
    TextEditingController groupNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新增群組'),
          content: Column(
            children: [
              TextField(
                controller: groupNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '群組名稱',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  XFile? imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (imageFile != null) {
                    image = await imageFile.readAsBytes();
                  }
                },
                child: const Text('照片上傳'),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                GoodsGroupProvider().insert(GoodsGroupItem(groupNameController.text, image: image));
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('確定'),
            ),
          ],
        );
      },
    );
  }

  void addProduct(GoodsGroupItem group) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('新增商品至 『${group.name}』'),
            content: inputWidget(group.id!),
          );
        });
  }

  void editproduct(Good good) {
    TextEditingController nameController = TextEditingController(text: good.name);
    TextEditingController priceController = TextEditingController(text: good.price.toString());
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('修改 ${good.name}'),
            content: Column(children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Product Name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Product Price',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    good.image = await image.readAsBytes();
                  }
                },
                child: const Text('選擇產品圖片'),
              ),
              ElevatedButton(
                onPressed: () {
                  good.name = nameController.text;
                  good.price = double.parse(priceController.text);
                  goodsProvider.update(good);
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text('修改產品'),
              ),
              ElevatedButton(
                onPressed: () {
                  goodsProvider.delete(good.id!);
                  setState(() {});
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('刪除產品'),
              )
            ]),
          );
        });
  }
}
