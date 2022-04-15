import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '/Screens/add_or_edit_notes.dart';
import '/models/data_models.dart';
import '/providers/task_provider.dart';
import '/widgets/subtask_list_widget.dart';
import 'package:provider/provider.dart';

class TaskListWidget extends StatefulWidget {
  final Task? task;
  final int? index;
  final VoidCallback? onFinish;
  const TaskListWidget({Key? key, this.task, this.index, this.onFinish})
      : super(key: key);

  @override
  TaskListWidgetState createState() => TaskListWidgetState();
}

class TaskListWidgetState extends State<TaskListWidget> {
  var isExpanded = false;
  var isSelected = false;

  @override
  Widget build(BuildContext context) {
    final tp = Provider.of<TaskProvider>(context);
    if (!tp.taskSelection) isSelected = false;

    return InkWell(
      onTap: () {
        if (tp.taskSelection) {
          setState(() {
            isSelected = !isSelected;
          });
          if (isSelected) {
            tp.selectedListIndexInsert(widget.task!.taskId);
          } else {
            tp.selectedListIndexRemove(widget.task!.taskId);
          }
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddTask(
                    task: widget.task,
                  )));
        }
      },
      onLongPress: () {
        if (isSelected) return;
        isSelected = true;
        if (isSelected) {
          tp.selectedListIndexInsert(widget.task!.taskId);
        }
        tp.setTaskSelection();
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 5,
        shadowColor: Colors.purple,
        child: Dismissible(
          direction: DismissDirection.endToStart,
          key: ObjectKey(widget.task?.taskId),
          onDismissed: (val) {
            tp.selectedList.add(widget.task?.taskId);
            tp.deleteSelected();
          },
          background: Container(
            color: Colors.redAccent,
            alignment: Alignment.centerRight,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: FaIcon(
                FontAwesomeIcons.trash,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          child: AnimatedContainer(
            constraints: const BoxConstraints(maxHeight: double.infinity),
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: (tp.taskSelection && isSelected)
                  ? Colors.lightBlueAccent
                  : Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                Container(
                  constraints: const BoxConstraints(maxHeight: double.infinity),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 3.0, left: 3.0, right: 3.0),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.solidFlag,
                            color: Priority.getColorForPriority(
                                widget.task!.priorityName),
                            size: 25,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          constraints:
                              const BoxConstraints(maxHeight: double.infinity),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3.0, left: 3.0),
                            child: Text(
                              widget.task!.taskTitle,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: IconButton(
                          icon: FaIcon(
                            (isExpanded)
                                ? FontAwesomeIcons.angleUp
                                : FontAwesomeIcons.angleDown,
                            color: (widget.task!.subTaskList.isEmpty)
                                ? Colors.grey
                                : Colors.black,
                            size: 25,
                          ),
                          onPressed: () {
                            if (widget.task!.subTaskList.isEmpty) return;
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 27,
                    ),
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: Checkbox(
                          value: widget.task?.isCompleted,
                          onChanged: (val) => widget.onFinish!()),
                    ),
                    const Text("Finished"),
                    const SizedBox(
                      width: 30,
                    ),
                    Text(
                      widget.task!.typeName,
                      style: const TextStyle(decoration: TextDecoration.underline),
                    ),
                  ],
                ),
                if (widget.task?.dueDate != null)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 27,
                          ),
                          const FaIcon(FontAwesomeIcons.clock,size: 20,),
                          const SizedBox(
                            width: 10,
                          ),
                          if (widget.task?.dueDate != null)
                            Text(
                              (widget.task?.dueDate?.year ==
                                          DateTime.now().year &&
                                      widget.task?.dueDate?.month ==
                                          DateTime.now().month &&
                                      widget.task?.dueDate?.day ==
                                          DateTime.now().day)
                                  ? "Today"
                                  : DateFormat.yMMMd().format(widget.task!.dueDate as DateTime),
                              style: TextStyle(
                                color: (widget.task?.dueTime != null)
                                    ? (DateTime(
                                                widget.task!.dueDate!.year,
                                                widget.task!.dueDate!.month,
                                                widget.task!.dueDate!.day,
                                                widget.task!.dueTime!.hour,
                                                widget.task!.dueTime!.minute)
                                            .isBefore(DateTime.now())
                                        ? Colors.red
                                        : Colors.black)
                                    : ((DateTime(
                                                widget.task!.dueDate!.year,
                                                widget.task!.dueDate!.month,
                                                widget.task!.dueDate!.day)
                                            .isBefore(DateTime.now()))
                                        ? Colors.red
                                        : Colors.black),
                              ),
                              softWrap: true,
                            ),
                          if (widget.task?.dueTime != null)
                            Text(
                              ",${widget.task?.dueTime?.format(context)}",
                              style: TextStyle(
                                  color: (DateTime(
                                              widget.task!.dueDate!.year,
                                              widget.task!.dueDate!.month,
                                              widget.task!.dueDate!.day,
                                              widget.task!.dueTime!.hour,
                                              widget.task!.dueTime!.minute)
                                          .isBefore(DateTime.now()))
                                      ? Colors.red
                                      : Colors.black),
                              softWrap: true,
                            ),
                        ],
                      ),
                    ),
                  ),
                if (isExpanded)
                  ClipRRect(
                    child: SubTaskListWidget(widget.task!),
                  ),
                const SizedBox(
                  height: 5,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
