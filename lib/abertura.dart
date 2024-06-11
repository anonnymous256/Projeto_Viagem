import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Login.dart';

class Abertura extends StatefulWidget {
  @override
  _AberturaState createState() => _AberturaState();
}

class _AberturaState extends State<Abertura> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String _userId;

  final List<Map<String, dynamic>> squares = [];
  final List<String> images = [
    'lib/assets/image/alemanha.png',
    'lib/assets/image/franca.png',
    'lib/assets/image/brasil.jpeg',
    'lib/assets/image/argentina.jpeg',
    'lib/assets/image/italia.jpeg',
    'lib/assets/image/inverno.jpg',
    'lib/assets/image/paisagem.jpeg',
    'lib/assets/image/parque.jpg',
    'lib/assets/image/praia.jpeg',
    'lib/assets/image/inicial.png',
  ];

  String selectedImage = '';

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
      _fetchViagens();
    }
  }

  void _fetchViagens() {
    _firestore
        .collection('viagens')
        .where('userId', isEqualTo: _userId)
        .get()
        .then((querySnapshot) {
      setState(() {
        squares.clear();
        querySnapshot.docs.forEach((doc) {
          squares.add({
            'id': doc.id,
            'title': doc['title'],
            'description': doc['description'],
            'budget': doc['budget'],
            'image': doc['image'],
          });
        });
      });
    }).catchError((error) {
      print('Erro ao buscar viagens: $error');
    });
  }

  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aviso'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showexcluirtDialog(BuildContext context, String message, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aviso'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('excluir'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                _removerViagem(index);
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddSquareDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController budgetController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionando Viagem'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Lugar',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'O que você pretende fazer na viagem?',
                ),
              ),
              TextField(
                controller: budgetController,
                decoration: InputDecoration(
                  labelText: 'Quanto você pretende gastar na viagem?',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showChooseCoverDialog,
                child: Text('Escolher Capa'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Adicionar'),
              onPressed: () {
                if (selectedImage == '' || titleController.text == '') {
                  showAlertDialog(context, 'Escolha uma capa e um titulo!');
                  return;
                }
                _adicionarViagem(
                  titleController.text,
                  descriptionController.text,
                  budgetController.text,
                  selectedImage,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showChooseCoverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Escolher Capa'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: images.map((image) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImage = image;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedImage == image
                            ? Colors.blue
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Image.asset(
                      image,
                      width: 50,
                      height: 50,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _adicionarViagem(
    String title,
    String description,
    String budget,
    String image,
  ) {
    _firestore.collection('viagens').add({
      'userId': _userId,
      'title': title,
      'description': description,
      'budget': budget,
      'image': image,
    }).then((value) {
      print('Viagem adicionada com sucesso!');
      _fetchViagens();
    }).catchError((error) {
      print('Erro ao adicionar viagem: $error');
    });
  }

  void _showEditSquareDialog(int index) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController budgetController = TextEditingController();

    titleController.text = squares[index]['title'] ?? '';
    descriptionController.text = squares[index]['description'] ?? '';
    budgetController.text = squares[index]['budget'] ?? '';
    selectedImage = squares[index]['image'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Viagem'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'O que você pretende fazerna viagem?',
),
),
TextField(
controller: budgetController,
decoration: InputDecoration(
labelText: 'Quanto você pretende gastar na viagem?',
),
keyboardType: TextInputType.number,
),
SizedBox(height: 20),
ElevatedButton(
onPressed: _showChooseCoverDialog,
child: Text('Alterar capa'),
),
],
),
actions: [
TextButton(
child: Text('Cancelar'),
onPressed: () {
Navigator.of(context).pop();
},
),
ElevatedButton(
child: Text('Salvar'),
onPressed: () {
_editarViagem(
squares[index]['id'],
titleController.text,
descriptionController.text,
budgetController.text,
selectedImage,
);
Navigator.of(context).pop();
},
),
],
);
},
);
}

void _editarViagem(
String id,
String title,
String description,
String budget,
String image,
) {
_firestore.collection('viagens').doc(id).update({
'title': title,
'description': description,
'budget': budget,
'image': image,
}).then((value) {
print('Viagem editada com sucesso!');
_fetchViagens();
}).catchError((error) {
print('Erro ao editar viagem: $error');
});
}

void _removerViagem(int index) {
String id = squares[index]['id'];
_firestore.collection('viagens').doc(id).delete().then((value) {
setState(() {
squares.removeAt(index);
});
print('Viagem removida com sucesso!');
}).catchError((error) {
print('Erro ao remover viagem: $error');
});
}

void _logout() async {
  Navigator.of(context).pushReplacement(MaterialPageRoute(
    builder: (context) => LoginPage(),
  ));
}
@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
home: Scaffold(
appBar: AppBar(
backgroundColor: Color.fromARGB(207, 1, 167, 179),
title: Text('Viagens'),
actions: [
IconButton(
onPressed: () => _logout(),
icon: Icon(Icons.exit_to_app),
),
],
),
body: Stack(
children: [
Center(
child: Container(
width: double.infinity,
height: double.infinity,
decoration: BoxDecoration(
image: DecorationImage(
image: AssetImage('lib/assets/image/inicial.png'),
fit: BoxFit.cover,
),
),
),
),
Column(
children: [
Spacer(flex: 1),
Expanded(
flex: 1,
child: Column(
children: [
Expanded(
child: GridView.builder(
gridDelegate:
SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 3,
childAspectRatio: 1,
),
itemCount: squares.length,
itemBuilder: (context, index) {
final square = squares[index];
return GestureDetector(
onTap: () {
showDialog(
context: context,
builder: (BuildContext context) {
return AlertDialog(
title: Text(square['title'] ?? ''),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
Text(
"Descrição: ${square['description'] ?? ''}"),
Text(
"Orçamento: ${square['budget'] ?? ''}"),
square['image'] != null
? Image.asset(
square['image'],
width: 100,
height: 100,
)
: SizedBox(),
],
),
actions: [
ElevatedButton(
onPressed: () =>
_showEditSquareDialog(index),
child: Text('Editar'),
),
ElevatedButton(
onPressed: () {
showexcluirtDialog(
context,
'Deseja excluir essa viagem permanentimente?',
index);
},
child: Text('Excluir'),
),
],
);
},
);
},
child: Container(
margin: EdgeInsets.all(10),
color: Color.fromARGB(255, 255, 255, 255)
.withOpacity(0.8),
child: Column(
children: [
Text(square['title'] ?? ''),
square['image'] != null
? Image.asset(
square['image'],
width: 85,
height: 85,
)
: SizedBox(),
],
),
),
);
},
),
),
ElevatedButton(
onPressed: _showAddSquareDialog,
style: ElevatedButton.styleFrom(
backgroundColor: Color.fromARGB(207, 1, 167, 179),
),
child: Text(
'Adicionar Viagem',
style: TextStyle(
color: Colors.black,
),
),
),
],
),
),
],
),
],
),
),
);
}
}