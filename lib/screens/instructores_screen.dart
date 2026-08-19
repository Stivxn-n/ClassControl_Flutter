import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/sidebar.dart';
import '../services/remote_data_service.dart';
import '../services/api_client.dart';
import '../widgets/page_header.dart';

class InstructoresScreen extends StatefulWidget {
  final String rol;
  const InstructoresScreen({super.key, required this.rol});
  @override State<InstructoresScreen> createState() => _InstructoresScreenState();
}

class _InstructoresScreenState extends State<InstructoresScreen> {
  final _search = TextEditingController();
  List<Map<String,dynamic>> _items = [];
  String? _error;
  bool _loading = true;

  @override void initState(){super.initState(); _load();}

  Future<void> _load() async {
    setState(()=>_loading=true);
    try {
      final users = await RemoteDataService.instance.list('/ConsultarUsuarios');
      final roles = await RemoteDataService.instance.list('/ConsultarRoles');
      final instructorIds = roles.where((r) =>
        '${r['descripcion']}'.toLowerCase().contains('instructor'))
        .map((r)=>r['id']).toSet();
      final data = instructorIds.isEmpty
        ? users
        : users.where((u)=>instructorIds.contains(u['rolId'])).toList();
      if(mounted) setState(()=>_items=data);
    } on ApiException catch(e) {
      if(mounted) setState(()=>_error=e.mensaje);
    } catch(_) {
      if(mounted) setState(()=>_error='No se pudo cargar los instructores.');
    } finally { if(mounted) setState(()=>_loading=false); }
  }

  @override Widget build(BuildContext context){
    final q=_search.text.toLowerCase();
    final data=_items.where((u){
      final s='${u['nombres']} ${u['apellidos']} ${u['correo']} ${u['identificacion']}';
      return q.isEmpty || s.toLowerCase().contains(q);
    }).toList();
    return Scaffold(body:Row(children:[
      Sidebar(rol:widget.rol,paginaActual:'instructores'),
      Expanded(child:Column(children:[
        const Padding(padding:EdgeInsets.fromLTRB(32,28,32,0),child:PageHeader(title:'Instructores',subtitle:'Consulta los instructores registrados.')),
        Padding(padding:const EdgeInsets.symmetric(horizontal:32,vertical:8),child:TextField(
          controller:_search,onChanged:(_)=>setState((){}),
          decoration:InputDecoration(prefixIcon:const Icon(Icons.search),hintText:'Buscar instructor...',
            border:OutlineInputBorder(borderRadius:BorderRadius.circular(10))))),
        Expanded(child:_loading?const Center(child:CircularProgressIndicator()):
          _error!=null?Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
            Text(_error!),const SizedBox(height:12),ElevatedButton(onPressed:_load,child:const Text('Reintentar'))
          ])):RefreshIndicator(onRefresh:_load,child:ListView.builder(
            padding:const EdgeInsets.fromLTRB(32,8,32,32),itemCount:data.length,
            itemBuilder:(context,i){
              final u=data[i];
              return Card(child:ListTile(
                leading:const CircleAvatar(child:Icon(Icons.person)),
                title:Text('${u['nombres']??''} ${u['apellidos']??''}',style:GoogleFonts.dmSans(fontWeight:FontWeight.w600)),
                subtitle:Text('${u['correo']??'-'} • Doc: ${u['identificacion']??'-'} • ${u['activo']==true?'Activo':'Inactivo'}'),
              ));
            })))
      ]))
    ]));
  }
}
