import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/models/data_models.dart';
import 'package:speech_to_text/speech_to_text.dart';


class SubTaskWidget extends StatefulWidget {
  final SubTask? newTask;
  final int? index;
  final VoidCallback? removeTask;
  const SubTaskWidget({Key? key,this.newTask,this.index,this.removeTask}) : super(key:key);
  
  @override
  SubTaskWidgetState createState() => SubTaskWidgetState();
}

class SubTaskWidgetState extends State<SubTaskWidget> {
  TextEditingController taskTitleText = TextEditingController();
  bool isTaskTitleValid = true;
  late SpeechToText speech;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    speech = SpeechToText();
    taskTitleText.text = widget.newTask!.subTaskTitle;
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
        onError: (val) {
          setState(() {
            isListening = false;
          });
          speech.stop();
        },
      );
      if (available) {
        setState(() => isListening = true);
        speech.listen(
          onResult: (val) => setState(() {
            taskTitleText.text=val.recognizedWords;
            taskTitleText.selection = TextSelection.collapsed(offset: taskTitleText.text.length);
            widget.newTask?.subTaskTitle=val.recognizedWords;
          }),
          listenFor: const Duration(seconds: 20),
        );

      } else {
        setState(() => isListening = false);
        speech.stop();
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }

  void submitTask(){
    if(widget.newTask?.subTaskTitle==''){
      setState(() {
        isTaskTitleValid= false;
      });
      return;
    }
    setState(() {
      isTaskTitleValid= true;
    });
  }


  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width*0.6,
              child: TextField(
                controller: taskTitleText,
                cursorColor: Colors.purpleAccent,
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.purpleAccent)),
                  labelText: "Enter sub task ${widget.index!+1}",
                  errorText: (isTaskTitleValid)?null:"Task cannot be empty",
                  labelStyle: const TextStyle(fontSize: 15),
                ),
                onChanged: (value){
                  setState(() {
                    taskTitleText.value= taskTitleText.value.copyWith(
                        text: value,
                        selection: TextSelection(baseOffset: value.length,extentOffset: value.length),
                        composing: TextRange.empty
                    );
                    isTaskTitleValid= true;
                    widget.newTask?.subTaskTitle=value;
                  });
                },
                onSubmitted: (val){
                  widget.newTask?.subTaskTitle=val;
                },
              ),
            ),
            AvatarGlow(
              animate: isListening,
              glowColor: (isListening)?Colors.purple:Colors.black,
              duration: const Duration(milliseconds: 1000),
              repeatPauseDuration: const Duration(milliseconds: 100),
              repeat: true,
              endRadius: 25,
              child: IconButton(
                icon: FaIcon(FontAwesomeIcons.microphoneLines,color: (isListening)?Colors.purple:Colors.black,),
                onPressed: () {
                  listen();
                },
              ),
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.trash,size: 20,),
              color: Colors.red,
              onPressed: widget.removeTask
            )
          ],
        ),

      ],
    );
  }
}
