
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/Screens/add_or_edit_notes.dart';

import '/models/data_models.dart';
import '/providers/task_provider.dart';
import '/widgets/task_list.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';



class HomeScreen extends StatefulWidget{
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  bool isListening =false;

  late SpeechToText speech;

  TextEditingController taskTitleText = TextEditingController();
  
  Task newTask=Task(0,'',null,null,'Never',false,'Moderate','Default',false,false,[]);

  bool isTaskTitleValid=true;

  @override
  void initState() {
    super.initState();
    speech = SpeechToText();
  }



  Widget buildHeadingContainer(String text,bool isWarning){
    return Container(
      padding: const EdgeInsets.only(top: 15,bottom: 5,left: 5),
      child: Text(
        text,
        style: TextStyle(
            color: (isWarning)?Colors.red:Colors.purpleAccent,
            fontSize: 18,
            ),
      ),
    );
  }

  void listen() async {
    if (!isListening) {
      bool available = await speech.initialize(
        onStatus: (val) {
          if(val=="notListening"){
            setState(() => isListening = false);
            speech.stop();
          }
        },
        onError: (val) => {},
      );
      if (available) {
        setState(() => isListening = true);
        speech.listen(
          onResult: (val) => setState(() {
            taskTitleText.text=val.recognizedWords;
            taskTitleText.selection = TextSelection.collapsed(offset: taskTitleText.text.length);
            newTask.taskTitle=val.recognizedWords;
          }),
          listenFor: const Duration(seconds: 20),
        );

      }

    } else {
      setState(() => isListening = false);
      speech.stop();
    }

  }

  void submitTask(){
    if(taskTitleText.text==''){
      setState(() {
        isTaskTitleValid= false;
      });
      return;
    }
    taskTitleText.text="";
    Provider.of<TaskProvider>(context,listen: false).addTask(newTask);
    FocusManager.instance.primaryFocus?.unfocus();
    newTask.taskTitle="";
  }


  @override
  Widget build(BuildContext context) {
    final tp = Provider.of<TaskProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        if(tp.taskSelection) {
          tp.setTaskSelection();
          return  false;
        }
        return true;
      },
      child: Scaffold(
        appBar: (tp.taskSelection)? AppBar(
          backgroundColor: Colors.purple,
          title: const Text(
            "Select Tasks",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.squareCheck,color: Colors.white,size: 20,),
              onPressed: (){
                tp.markAsCompleted();
              },
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.trash,size: 20,color: Colors.white,),
              onPressed: (){
                    tp.deleteSelected();
              },
            ),

          ],
        ):AppBar(
          title: DropdownButton(
            hint: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Text(
                tp.typeValue,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            icon: const FaIcon(
              FontAwesomeIcons.caretDown,
              color: Color.fromRGBO(196, 197, 197, 1),
            ),
            items: <String>['All Tasks', 'Default','Home','Personal', 'Shopping','Work','Others','Finished']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(color: Colors.black),
                    ),
                    Text(
                      "(${tp.getItemsCount(value)})"
                    )
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
                tp.setTypeValue(value.toString());
            },
          ),
          backgroundColor: Colors.purple,
          actions: [
            Padding(
              padding: const EdgeInsets.all(3),
              child: IconButton(
                icon: const FaIcon(FontAwesomeIcons.plus),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const AddTask()));
                },
              ),
            ),
          ],
        ),
        body:
           GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                if(tp.taskSelection) {
                  tp.setTaskSelection();
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(tp.typeValue!="Finished")
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text(
                          "Sort By: ",
                          style: TextStyle(
                              fontSize: 18,

                              color: Colors.purpleAccent),
                        ),
                      ),
                      if(tp.typeValue!="Finished")
                      DropdownButton(
                        hint: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Text(
                            tp.sortValue,
                            style: const TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ),
                        icon: const FaIcon(
                          FontAwesomeIcons.caretDown,
                          color: Color.fromRGBO(196, 197, 197, 1),
                        ),
                        items: <String>[
                          'Date only',
                          'Date+Priority',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                            tp.setSortValue(value.toString());
                        },
                      ),
                    ],
                  ),
                  if(tp.sortValue=='Date only')
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width*0.97,
                      child: Scrollbar(
                        child: (tp.typeValue!="Finished")?ListView(
                          children: [
                            if(tp.dueTaskList.isNotEmpty )
                            buildHeadingContainer("Overdue",true),
                            if(tp.dueTaskList.isNotEmpty )
                            TaskList(tp.dueTaskList),
                            if(tp.todayTaskList.isNotEmpty )
                            buildHeadingContainer("Today", false),
                            if(tp.todayTaskList.isNotEmpty )
                            TaskList(tp.todayTaskList),
                            if(tp.tomorrowTaskList.isNotEmpty )
                            buildHeadingContainer("Tomorrow", false),
                            if(tp.tomorrowTaskList.isNotEmpty )
                            TaskList(tp.tomorrowTaskList),
                            if(tp.thisWeekTaskList.isNotEmpty )
                            buildHeadingContainer("This Week", false),
                            if(tp.thisWeekTaskList.isNotEmpty )
                            TaskList(tp.thisWeekTaskList),
                            if(tp.nextWeekTaskList.isNotEmpty )
                            buildHeadingContainer("Next Week", false),
                            if(tp.nextWeekTaskList.isNotEmpty )
                            TaskList(tp.nextWeekTaskList),
                            if(tp.thisMonthTaskList.isNotEmpty )
                            buildHeadingContainer("This Month", false),
                            if(tp.thisMonthTaskList.isNotEmpty )
                            TaskList(tp.thisMonthTaskList),
                            if(tp.laterTaskList.isNotEmpty )
                            buildHeadingContainer("Later", false),
                            if(tp.laterTaskList.isNotEmpty )
                            TaskList(tp.laterTaskList),
                            if(tp.noDueTaskList.isNotEmpty )
                              buildHeadingContainer("No due", false),
                            if(tp.noDueTaskList.isNotEmpty )
                              TaskList(tp.noDueTaskList),
                          ],
                        ):(tp.completedTaskList.isNotEmpty)?SingleChildScrollView(child: TaskList(tp.completedTaskList)):const Center(child: Text("N0 task has been completed")),
                      ),
                    ),
                  ),
                  if(tp.sortValue=='Date+Priority')
                    Expanded(
                      child: Scrollbar(
                        child: (tp.typeValue!="Finished")?ListView(
                          children: [
                            if(tp.veryHighPriorityList.isNotEmpty )
                              Container(
                                padding: const EdgeInsets.only(top: 15,bottom: 5,left: 5),
                                child: const Text(
                                         "Very Important",
                                         style: TextStyle(
                                                   color: Colors.red,
                                         fontSize: 18,
                                                        ),
                                           ),
                                   ),
                            if(tp.veryHighPriorityList.isNotEmpty )
                              TaskList(tp.veryHighPriorityList),
                            if(tp.highPriorityList.isNotEmpty )
                              Container(
                                padding: const EdgeInsets.only(top: 15,bottom: 5,left: 5),
                                child: const Text(
                                  "Important",
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            if(tp.highPriorityList.isNotEmpty )
                              TaskList(tp.highPriorityList),
                            if(tp.moderatePriorityList.isNotEmpty )
                              Container(
                                padding: const EdgeInsets.only(top: 15,bottom: 5,left: 5),
                                child: const Text(
                                  "Moderate",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            if(tp.moderatePriorityList.isNotEmpty )
                              TaskList(tp.moderatePriorityList),
                            if(tp.lowPriorityList.isNotEmpty )
                              Container(
                                padding: const EdgeInsets.only(top: 15,bottom: 5,left: 5),
                                child: const Text(
                                  "Less Important",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            if(tp.lowPriorityList.isNotEmpty )
                              TaskList(tp.lowPriorityList),
                          ],
                        ):(tp.completedTaskList.isNotEmpty)?SingleChildScrollView(child: TaskList(tp.completedTaskList)):const Center(child: Text("N0 task has been completed")),
                      ),
                    ),

                  Container(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.purple,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Material(
                            color: Colors.purple,
                            child: AvatarGlow(
                              animate: isListening,
                              glowColor: Colors.white,
                              duration: const Duration(milliseconds: 1000),
                              repeatPauseDuration: const Duration(milliseconds: 100),
                              repeat: true,
                              endRadius: 25,
                              child: IconButton(
                                icon: const FaIcon(FontAwesomeIcons.microphoneLines,color: Colors.white),
                                onPressed: () {
                                  listen();
                                },
                              ),
                            ),
                          ),
                          Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.65,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: TextField(
                                controller: taskTitleText,
                                decoration:
                                    InputDecoration(labelText: "Add a Quick Task here",errorText: (isTaskTitleValid)?null:"Enter a valid task"),
                                onChanged: (value){
                                  setState(() {

                                    newTask.taskTitle=value;
                                    isTaskTitleValid= true;
                                  });
                                },
                                onSubmitted: (val){
                                  newTask.taskTitle=val;
                                },
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.purple,
                            child: IconButton(
                              icon: const FaIcon(
                                FontAwesomeIcons.check,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                submitTask();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),


      ),
    );
  }
}
