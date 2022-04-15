

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '/models/data_models.dart';
import '/widgets/subtask_widget.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../providers/task_provider.dart';

class AddTask extends StatefulWidget {
  
  final Task? task;

  const AddTask({Key? key, this.task}) : super(key: key);


  @override
  AddTaskState createState() => AddTaskState();
}

class AddTaskState extends State<AddTask> {
  
  Task newTask = Task(0,'',null,null,"No Repeat",false,'Moderate','Default',false,false,[]);

  bool speechEnabled =false;

  SpeechToText speech = SpeechToText();

  TextEditingController taskTitleText = TextEditingController();

  bool isTaskTitleValid=true;
  
  String typeDropDownValue = "Default";

  Priority priorityDropDownValue = Priority.getPriorityList()[2];

  String repeatDropDownValue='No Repeat';

  bool isEdit=false;


  @override
  void initState() {
    super.initState();
    _initSpeech();
    if(widget.task!=null) {
       if (widget.task!.taskTitle != '') {
           newTask = widget.task!;
           isEdit = true;
           taskTitleText.text = newTask.taskTitle;
           typeDropDownValue = newTask.typeName;
           repeatDropDownValue = newTask.repeatTask;
           priorityDropDownValue = Priority.getPriorityList().firstWhere((element) => element.priorityName == newTask.priorityName);
      }
    }
  }

  void _initSpeech() async {
    speechEnabled = await speech.initialize();
    setState(() {});
  }

  void _startListening() async {
    await speech.listen(onResult: _onSpeechResult,listenFor: const Duration(seconds: 15));
    setState(() {});
  }

  void _stopListening() async {
    await speech.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      taskTitleText.text=result.recognizedWords;
      taskTitleText.selection = TextSelection.collapsed(offset: taskTitleText.text.length);
      newTask.taskTitle=result.recognizedWords;
    });
  }


  void updateList(){
    for(int i=0;i<newTask.subTaskList.length;i++){
      if(newTask.subTaskList[i].subTaskTitle==''){
        newTask.subTaskList.removeAt(i);
      }
    }
  }

  void submitTask() async{
    if(taskTitleText.text==''){
      setState(() {
        isTaskTitleValid= false;
      });
      return;
    }
    if(isEdit) {
      widget.task?.taskTitle=taskTitleText.text;
    }
    setState(() {
      isTaskTitleValid= true;
      updateList();
    });
    if(isEdit){
      Provider.of<TaskProvider>(context,listen: false).updateTask(newTask);
      if(newTask.dueDate!=null){
        await Provider.of<TaskProvider>(context,listen: false).showNotification(newTask, newTask.taskId, true);
      }

    }else {
      int id= await Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
      if(newTask.dueDate!=null){
        if(!mounted) return;
        await Provider.of<TaskProvider>(context,listen: false).showNotification(newTask, id, false);
      }

    }
    if(!mounted) return;
    Navigator.of(context).pop();
  }

  void removeSubTask(SubTask item){
    newTask.subTaskList.remove(item);
    if(isEdit){
      Provider.of<TaskProvider>(context,listen: false).deleteSubTask(item.subTaskId);
    }
    setState(() {});
  }

  Widget defaultHeadingContainer(String text){
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: const TextStyle(color: Colors.purple,fontSize: 15),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final tp = Provider.of<TaskProvider>(context,listen: false);
    var typeList = tp.getTypeList.map((e) => e.typeName).toList();
    return WillPopScope(
      onWillPop: () async =>true,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowLeft,color: Colors.white,),
              onPressed: () =>Navigator.of(context).pop(),
                  
          ),
          title: Text(
            (isEdit)?"Edit Task":"Add a Task",
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width*0.95,
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //title field
                            defaultHeadingContainer("What is to be done?"),
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width*0.7,
                                  child: TextField(
                                    cursorColor: Colors.purpleAccent,
                                    controller: taskTitleText,
                                    decoration: InputDecoration(
                                      labelText: "Enter the Task e.g: go to party",
                                      errorText: (isTaskTitleValid)?null:"Task cannot be empty",
                                      labelStyle: const TextStyle(fontSize: 15),
                                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.purpleAccent))
                                    ),
                                    onChanged: (value){
                                      setState(() {

                                            isTaskTitleValid= true;
                                            if(!isEdit){
                                              newTask.taskTitle=value;
                                            }
                                      });
                                    },
                                    onSubmitted: (val){
                                      newTask.taskTitle=val;
                                    },
                                  ),
                                ),
                                AvatarGlow(
                                  animate: speech.isListening,
                                  glowColor: Colors.purple,
                                  duration: const Duration(milliseconds: 1000),
                                  repeatPauseDuration: const Duration(milliseconds: 100),
                                  repeat: true,
                                  endRadius: 25,
                                  child: IconButton(
                                    icon: const FaIcon(FontAwesomeIcons.microphoneLines,color: Colors.purple,),
                                    onPressed: () {
                                      if(speech.isListening && speechEnabled) {
                                        _stopListening();
                                      } else {
                                        _startListening();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            //date field
                            defaultHeadingContainer("Select Due Date"),
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width*0.7,
                                  child: TextField(
                                    enabled: false,
                                    decoration: InputDecoration(
                                        labelText: (newTask.dueDate==null)?"Due Date":DateFormat.yMMMd().format(newTask.dueDate!),
                                      labelStyle: const TextStyle(fontSize: 15,color: Colors.black),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.calendarCheck),
                                  onPressed: () =>showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                  ).then((value) {
                                    setState(() {
                                      newTask.dueDate=(value!=null)?value:null;
                                      newTask.dueTime=(value!=null)?const TimeOfDay(hour: 23,minute: 59):null;
                                    });
                                  }
                                  )
                                ),
                              ],
                            ),
                            //time field
                            if(newTask.dueDate != null)
                            defaultHeadingContainer("Select time"),
                            if(newTask.dueDate != null)
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width*0.7,
                                  child: TextField(
                                    enabled: false,
                                    decoration: InputDecoration(
                                        labelText: (newTask.dueTime==null)?"Due Time":newTask.dueTime?.format(context),
                                      labelStyle: const TextStyle(fontSize: 15,color: Colors.black),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.clock),
                                  onPressed: () =>showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                      cancelText: "Back",
                                      confirmText: "Ok"
                                  ).then((value) {
                                    setState(() {
                                      newTask.dueTime= (value!=null)?value:const TimeOfDay(hour: 23,minute: 59);
                                    });
                                  }
                                  )
                                ),
                              ],
                            ),
                            defaultHeadingContainer("Set it's type"),
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width*0.7,
                                  child: DropdownButton(
                                    hint: Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width*0.6,
                                        child: Text(
                                          typeDropDownValue,
                                          style: const TextStyle(color: Colors.black, fontSize: 15),
                                        ),
                                      ),
                                    ),
                                    icon: const FaIcon(
                                      FontAwesomeIcons.caretDown,
                                      color: Color.fromRGBO(196, 197, 197, 1),
                                    ),
                                    items: typeList.map<DropdownMenuItem<String>>((String val) {
                                      return DropdownMenuItem(
                                        value: val,
                                        child: Text(
                                          val,
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        typeDropDownValue = value.toString();
                                        newTask.typeName = value.toString();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            defaultHeadingContainer("Set Priority"),
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width*0.7,
                                  child: DropdownButton(
                                    hint: Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width*0.6,
                                        child: Row(
                                          children: [
                                            FaIcon(FontAwesomeIcons.solidFlag,color: priorityDropDownValue.color,size: 20,),
                                            const SizedBox(width: 10),
                                            Text(
                                              priorityDropDownValue.priorityName,
                                              style: const TextStyle(color: Colors.black, fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    icon: const FaIcon(
                                      FontAwesomeIcons.caretDown,
                                      color: Color.fromRGBO(196, 197, 197, 1),
                                    ),
                                    items: Priority.getPriorityList().map<DropdownMenuItem<Priority>>((Priority val) {
                                      return DropdownMenuItem(
                                        value: val,
                                        child: Row(
                                          children: [
                                            FaIcon(FontAwesomeIcons.solidFlag,color: val.color,size: 20,),
                                            const SizedBox(width: 10),
                                            Text(
                                              val.priorityName,
                                              style: const TextStyle(color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      value as Priority;
                                      setState(() {
                                        priorityDropDownValue = value;
                                        newTask.priorityName= value.priorityName;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            defaultHeadingContainer("Repeat"),
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width*0.7,
                                  child: DropdownButton(
                                    hint: Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width*0.6,
                                        child: Text(
                                          repeatDropDownValue,
                                          style: const TextStyle(color: Colors.black, fontSize: 15),
                                        ),
                                      ),
                                    ),
                                    icon: const FaIcon(
                                      FontAwesomeIcons.caretDown,
                                      color: Color.fromRGBO(196, 197, 197, 1),
                                    ),
                                    items: ["No Repeat","Daily","Two Days Once","Weekly","Monthly","Yearly"].map<DropdownMenuItem<String>>((String val) {
                                      return DropdownMenuItem(
                                        value: val,
                                        child: Text(
                                          val,
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {

                                      setState(() {
                                        repeatDropDownValue = value.toString();
                                        newTask.repeatTask = value.toString();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if(newTask.subTaskList.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: newTask.subTaskList.length,
                                itemBuilder: (context,index) {
                                final item = newTask.subTaskList[index];
                                return SubTaskWidget(
                                    key:ObjectKey(item),
                                    newTask:item,
                                    index:index,
                                    removeTask:()=>removeSubTask(item)
                                );
                                },
                            ),
                            Center(
                              child: TextButton(
                                child: const Text(
                                  "Add a sub task",
                                  style: TextStyle(decoration: TextDecoration.underline,color: Colors.purple),
                                ),
                                onPressed: (){
                                  setState(() {
                                    var newSubTask = SubTask("",0,newTask.taskId,false);
                                    newTask.subTaskList.add(newSubTask);
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  color: Colors.purple,
                  child: TextButton(

                    child: Text((isEdit)?"Update Task":"Add Task",style: const TextStyle(color: Colors.white),),
                    onPressed: () {
                      submitTask();
                    },
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
