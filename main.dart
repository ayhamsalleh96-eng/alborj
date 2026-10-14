import 'package:flutter/material.dart';

void main() => runApp(const AlBoriDebtApp());

class AlBoriDebtApp extends StatelessWidget {
  const AlBoriDebtApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'البرج ديون', debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF101F52)), scaffoldBackgroundColor: Colors.grey[100], useMaterial3: true),
    builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child ?? const SizedBox.shrink()),
    home: const LoginScreen(),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController();
  final password = TextEditingController();
  void login() {
    final u = username.text.trim(), p = password.text.trim();
    if ((u == 'admin' && p == '1234') || (u == 'worker' && p == '1111')) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(workerName: u)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اسم المستخدم أو كلمة المرور غير صحيحة')));
    }
  }
  @override void dispose() { username.dispose(); password.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.asset('assets/albori_logo.jpg', width: 140, height: 140, fit: BoxFit.cover)),
    const SizedBox(height: 16), const Text('البرج ديون', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: Color(0xFF101F52))),
    const Text('إدارة ديون متجر الأكسسوارات والخدمات', style: TextStyle(color: Colors.grey)), const SizedBox(height: 32),
    TextField(controller: username, decoration: const InputDecoration(labelText: 'اسم المستخدم', prefixIcon: Icon(Icons.person), border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
    const SizedBox(height: 16), TextField(controller: password, obscureText: true, onSubmitted: (_) => login(), decoration: const InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
    const SizedBox(height: 24), SizedBox(width: double.infinity, height: 52, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF101F52), foregroundColor: Colors.white), onPressed: login, child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 18)))),
  ]))));
}

class HomeScreen extends StatefulWidget {
  final String workerName;
  const HomeScreen({super.key, required this.workerName});
  @override State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> customers = [
    {'name':'أحمد علي','phone':'0912345678','balance':15.0,'history':[{'type':'دَيْن جديد','amount':15.0,'service':'أكسسوارات','date':'2026-10-14','notes':'جراب + زجاجة حماية','worker':'admin'}]},
    {'name':'محمد حسن','phone':'0987654321','balance':5.0,'history':[{'type':'دَيْن جديد','amount':10.0,'service':'رصيد','date':'2026-10-13','notes':'تحويل رصيد','worker':'admin'},{'type':'تسديد','amount':5.0,'service':'دفعة نقدية','date':'2026-10-14','notes':'دفع جزء من الحساب','worker':'admin'}]},
  ];
  void addCustomer() {
    final name = TextEditingController(), phone = TextEditingController();
    showDialog(context: context, builder: (dialogContext) => AlertDialog(title: const Text('إضافة زبون جديد'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم الزبون')), TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الهاتف'))]), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')), ElevatedButton(onPressed: () { if (name.text.trim().isEmpty) return; setState(() => customers.add({'name':name.text.trim(),'phone':phone.text.trim(),'balance':0.0,'history':<Map<String,dynamic>>[]})); Navigator.pop(dialogContext); }, child: const Text('حفظ'))])).then((_) { name.dispose(); phone.dispose(); });
  }
  void transaction(Map<String,dynamic> customer, bool debt) {
    final amount = TextEditingController(), notes = TextEditingController();
    String service = 'أكسسوارات';
    showDialog(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, refresh) => AlertDialog(title: Text(debt ? 'إضافة دَيْن على: ${customer['name']}' : 'تسديد دفعة لـ: ${customer['name']}'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [if (debt) DropdownButtonFormField<String>(value: service, items: ['أكسسوارات','رصيد','فاتورة إنترنت','فاتورة هاتف'].map((s) => DropdownMenuItem(value:s, child:Text(s))).toList(), onChanged: (v) { if (v != null) refresh(() => service = v); }, decoration: const InputDecoration(labelText:'نوع الخدمة / البضاعة')), const SizedBox(height:12), TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal:true), decoration: const InputDecoration(labelText:'المبلغ')), const SizedBox(height:12), TextField(controller: notes, decoration: const InputDecoration(labelText:'ملاحظات (اختياري)'))])), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')), ElevatedButton(onPressed: () { final value = double.tryParse(amount.text.replaceAll(',', '.')); if (value == null || value <= 0) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل مبلغاً صحيحاً أكبر من صفر'))); return; } setState(() { customer['balance'] = (customer['balance'] as num).toDouble() + (debt ? value : -value); (customer['history'] as List).add({'type':debt?'دَيْن جديد':'تسديد','amount':value,'service':debt?service:'دفعة نقدية','date':DateTime.now().toString().substring(0,10),'notes':notes.text.trim(),'worker':widget.workerName}); }); Navigator.pop(dialogContext); }, child: Text(debt?'تسجيل الدين':'تثبيت التسديد'))]))).then((_) { amount.dispose(); notes.dispose(); });
  }
  @override Widget build(BuildContext context) {
    final total = customers.fold<double>(0, (sum, c) => sum + (c['balance'] as num).toDouble());
    return Scaffold(appBar: AppBar(title: const Text('البرج ديون - دفتر الزبائن'), backgroundColor: const Color(0xFF101F52), foregroundColor: Colors.white, actions: [IconButton(tooltip:'تسجيل الخروج', icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()))) ]),
      body: Column(children: [Container(width: double.infinity, padding: const EdgeInsets.all(16), color: Colors.indigo[50], child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Flexible(child: Text('إجمالي الديون المعلقة:', style: TextStyle(fontSize:16,fontWeight:FontWeight.bold))), Text('\$${total.toStringAsFixed(2)}', style: TextStyle(fontSize:18,fontWeight:FontWeight.bold,color: total > 0 ? Colors.red[900] : Colors.green[900]))])), Expanded(child: customers.isEmpty ? const Center(child: Text('لا يوجد زبائن بعد')) : ListView.builder(itemCount: customers.length, itemBuilder: (_, i) { final c = customers[i]; final balance = (c['balance'] as num).toDouble(); final hasDebt = balance > 0; return Card(margin: const EdgeInsets.symmetric(horizontal:12,vertical:6), child: ListTile(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerDetailScreen(customer:c))), leading: CircleAvatar(backgroundColor: hasDebt ? Colors.red[100] : Colors.green[100], child: Text((c['name'] as String).isEmpty ? '?' : (c['name'] as String).substring(0,1), style: TextStyle(color: hasDebt ? Colors.red[900] : Colors.green[900]))), title: Text(c['name'], style: const TextStyle(fontWeight:FontWeight.bold)), subtitle: Text('الهاتف: ${c['phone']}\nالمتبقي: \$${balance.toStringAsFixed(2)}'), isThreeLine:true, trailing: Wrap(spacing:0, children:[IconButton(tooltip:'إضافة دين', icon:const Icon(Icons.add_circle,color:Colors.red), onPressed:()=>transaction(c,true)), IconButton(tooltip:'تسديد', icon:const Icon(Icons.payment,color:Colors.green), onPressed:()=>transaction(c,false))])) ;} ))]), floatingActionButton: FloatingActionButton(backgroundColor: const Color(0xFF101F52), foregroundColor:Colors.white, onPressed:addCustomer, tooltip:'إضافة زبون', child:const Icon(Icons.person_add)));
  }
}

class CustomerDetailScreen extends StatelessWidget {
  final Map<String,dynamic> customer;
  const CustomerDetailScreen({super.key, required this.customer});
  @override Widget build(BuildContext context) {
    final history = customer['history'] as List;
    final balance = (customer['balance'] as num).toDouble();
    return Scaffold(appBar: AppBar(title: Text('كشف حساب: ${customer['name']}'), backgroundColor: const Color(0xFF101F52), foregroundColor:Colors.white), body: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Card(child: Padding(padding:const EdgeInsets.all(16), child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text('رقم الهاتف: ${customer['phone']}', style:const TextStyle(color:Colors.grey)), const SizedBox(height:8), const Text('الصافي المطلوب:', style:TextStyle(fontSize:16,fontWeight:FontWeight.bold))])), const SizedBox(width:12), Text('\$${balance.toStringAsFixed(2)}', style:TextStyle(fontSize:22,fontWeight:FontWeight.bold,color:balance>0?Colors.red:Colors.green))]))), const SizedBox(height:16), const Text('سجل الحركات السابقة:', style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)), const SizedBox(height:8), Expanded(child: history.isEmpty ? const Center(child:Text('لا توجد حركات مسجلة بعد',style:TextStyle(color:Colors.grey))) : ListView.builder(itemCount:history.length,itemBuilder:(_,i){final tx=history[i]; final debt=tx['type']=='دَيْن جديد'; return Card(child:ListTile(leading:Icon(debt?Icons.arrow_upward:Icons.arrow_downward,color:debt?Colors.red:Colors.green), title:Text('${tx['type']} (${tx['service']}) - \$${(tx['amount'] as num).toStringAsFixed(2)}'), subtitle:Text('التاريخ: ${tx['date']}\nملاحظات: ${tx['notes'] ?? 'لا يوجد'}'), trailing:Text('بواسطة: ${tx['worker'] ?? 'admin'}',style:const TextStyle(fontSize:11,color:Colors.grey))));} ))])));
  }
}
