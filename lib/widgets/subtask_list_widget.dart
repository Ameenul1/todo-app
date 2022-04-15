import 'package:flutter/material.dart';
import '/models/data_models.dart';
import '/providers/task_provider.dart';
import 'package:provider/provider.dart';

class SubTaskListWidget extends StatefulWidget {
  final Task task;

  const SubTaskListWidget(this.task, {Key? key, }) : super(key: key);


  @override
  SubTaskListWidgetState createState() => SubTaskListWidgetState();
}

class SubTaskListWidgetState extends State<SubTaskListWidget> {
  @override
  Widget build(BuildContext context) {
    final tp = Provider.of<TaskProvider>(context);
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.task.subTaskList.length,
        itemBuilder: (context, index) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Row(
              children: [
                Checkbox(
                  value: widget.task.subTaskList[index].isCompleted,
                  onChanged: (value) {
                    if(widget.task.isCompleted) {
                      if (!value!) {
                        widget.task.isCompleted = false;
                        tp.updateTask(widget.task);
                      }
                    }
                    widget.task.subTaskList[index].isCompleted=value!;
                    setState(() {

                    });
                    tp.updateSubTask(widget.task.subTaskList[index]);
                  },
                ),
                Text(widget.task.subTaskList[index].subTaskTitle)
              ],
            ),
          );
        });
  }
}
