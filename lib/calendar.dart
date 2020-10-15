import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_cal/calendar_model.dart';
import 'package:flutter_cal/db.dart';
import 'package:flutter_cal/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {

    DateTime _selectedDay = DateTime.now();

    CalendarController _calendarController;
     Map<DateTime, List<dynamic>> _events = {};
     List<CalendarItem> _data = [];

     List<dynamic> _selectedEvents = [];
     List<Widget> get _eventWidgets => _selectedEvents.map((e) => events(e)).toList();
  
  void initState() {
    super.initState();
    DB.init().then((value) => _fetchEvents());
    _calendarController = CalendarController();
  }

  void dispose(){
    _calendarController.dispose();
    super.dispose();
  }

  Widget events(var d){
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
          decoration: BoxDecoration(
              border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[Text(d,
                            style:
                                Theme.of(context).primaryTextTheme.bodyText1),
                                IconButton(icon: FaIcon(FontAwesomeIcons.trashAlt, color: Colors.redAccent, size: 15,), onPressed: ()=> _deleteEvent(d))
             ]) ),
        );  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedDay = day;
      _selectedEvents = events;
    });
  }

  void _create(BuildContext context) {
    String _name = "";
    var content = TextField(
      style: GoogleFonts.montserrat(
          color: Color.fromRGBO(105, 105, 108, 1), fontSize: 16),
      autofocus: true,
      decoration: InputDecoration(
        labelStyle: GoogleFonts.montserrat(
            color: Color.fromRGBO(59, 57, 60, 1),
            fontSize: 18,
            fontWeight: FontWeight.normal),
        labelText: 'Workout Name',
      ),
      onChanged: (value) {
        _name = value;
      },
    );
    var btn = FlatButton(
      child: Text('Save',
          style: GoogleFonts.montserrat(
              color: Color.fromRGBO(59, 57, 60, 1),
              fontSize: 16,
              fontWeight: FontWeight.bold)),
      onPressed: () => _addEvent(_name),
    );
    var cancelButton = FlatButton(
            child: Text('Cancel',
                style: GoogleFonts.montserrat(
                    color: Color.fromRGBO(59, 57, 60, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.of(context).pop(false));
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              SizedBox(height: 16.0),
              Text("Add Event", style: GoogleFonts.montserrat(
                color: Color.fromRGBO(59, 57, 60, 1),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
              Container(padding: EdgeInsets.all(20), child: content),
              Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[btn, cancelButton]),
            ],
          ),
        ),
      ],
    ),
      ),
    );
  }

  void _fetchEvents() async{
    _events = {};
    List<Map<String, dynamic>> _results = await DB.query(CalendarItem.table);
    _data = _results.map((item) => CalendarItem.fromMap(item)).toList();
      _data.forEach((element) {
        DateTime formattedDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.parse(element.date.toString())));
      if(_events.containsKey(formattedDate)){
        _events[formattedDate].add(element.name.toString());
      }
      else{
          _events[formattedDate] = [element.name.toString()];
        }
      }
    );
    setState(() {});
  }

  void _addEvent(String event) async{
    CalendarItem item = CalendarItem(
      date: _selectedDay.toString(),
      name: event
    );
    await DB.insert(CalendarItem.table, item);
    _selectedEvents.add(event);
    _fetchEvents();
    
    Navigator.pop(context);
  }

  // Delete doesnt refresh yet, thats it, then done!
  void _deleteEvent(String s){
    List<CalendarItem> d = _data.where((element) => element.name == s).toList();
    if(d.length == 1){
      DB.delete(CalendarItem.table, d[0]);
      _selectedEvents.removeWhere((e) => e == s);
      _fetchEvents();
    }
  }

  Widget calendar(){
    return Container(
      margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(colors: [Colors.red[600], Colors.red[400]]),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: new Offset(0.0, 5)
          )
        ]
      ),
      child: TableCalendar(
          
            calendarStyle: CalendarStyle(
              canEventMarkersOverflow: true,
              markersColor: Colors.white,
              weekdayStyle: TextStyle(color: Colors.white),
              
              todayColor: Colors.white54,
              todayStyle: TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.bold),
              selectedColor: Colors.red[900],
              outsideWeekendStyle: TextStyle(color: Colors.white60),
              outsideStyle: TextStyle(color: Colors.white60),
              weekendStyle: TextStyle(color: Colors.white),
              renderDaysOfWeek: false,
            ),
            onDaySelected: _onDaySelected,
            calendarController: _calendarController,
            events: _events, 
          
            headerStyle: HeaderStyle(
              leftChevronIcon: Icon(Icons.arrow_back_ios, size: 15, color: Colors.white),
              rightChevronIcon: Icon(Icons.arrow_forward_ios, size: 15, color: Colors.white),
              titleTextStyle: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 16)
              ,
              formatButtonDecoration: BoxDecoration(   
                color: Colors.white60,
                borderRadius: BorderRadius.circular(20),       
              ),
              formatButtonTextStyle: GoogleFonts.montserrat(
          color: Colors.red,
          fontSize: 13,
          fontWeight: FontWeight.bold),
            ),
            
      )
          );
  }

  Widget eventTitle(){
    if(_selectedEvents.length == 0){
      return Container(
              padding: EdgeInsets.fromLTRB(15, 20, 15, 15),
              child:Text("No events", style: Theme.of(context).primaryTextTheme.headline1),
            );
    }
    return Container(
              padding: EdgeInsets.fromLTRB(15, 20, 15, 15),
              child:Text("Events", style: Theme.of(context).primaryTextTheme.headline1),
            );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body:  ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(15),
              child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
              
              Text("Calendar", style: Theme.of(context).primaryTextTheme.headline1),
              Consumer<ThemeNotifier>(
                    builder: (context, notifier, child) => IconButton(icon: notifier.isDarkTheme ? FaIcon(FontAwesomeIcons.moon, size: 20, color: Colors.white,) : Icon(Icons.wb_sunny), onPressed: () => {notifier.toggleTheme()}))
            ],),
            ),
            
            calendar(),
            eventTitle(),
            Column(children:_eventWidgets),
            SizedBox(height:60)
          ],
        ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () => _create(context),
        child: Icon(Icons.add, color: Colors.white,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
