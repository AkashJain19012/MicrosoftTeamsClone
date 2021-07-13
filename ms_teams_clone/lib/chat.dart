import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/rendering.dart';
import 'package:ms_teams_clone/src/pages/call.dart';
import 'package:ms_teams_clone/src/utils/settings.dart';

class MyApp1 extends StatefulWidget {
  final String channelNametemp, userNametemp;
  final ClientRole roletemp;
  MyApp1(this.channelNametemp, this.userNametemp, this.roletemp);
  @override
  _MyApp1State createState() => _MyApp1State();
}

class _MyApp1State extends State<MyApp1> {
  String channelName, userName;
  ClientRole role;

  ///// create a channelMessageController to retrieve text value
  final _channelMessageController = TextEditingController();

  //stores all the info about the channel events
  final _infoStrings = <String>[];

  //stores all the messages and their sender
  final _messages = <Pair>[];

  AgoraRtmClient _client;
  AgoraRtmChannel _channel;

  @override
  void initState() {
    super.initState();
    channelName = widget.channelNametemp;
    userName = widget.userNametemp;
    print(userName);
    role = widget.roletemp;

    //creates a new client
    _createClient();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Microsoft Teams'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildJoin(),
            _buildChannelName(),
            _buildMessageList(),
            _buildSendChannelMessage(),
          ],
        ),
      ),
    );
  }

  void _createClient() async {
    //create an instance of agora rtm client using the app id
    _client = await AgoraRtmClient.createInstance(APP_ID);
    _toggleLogin();
  }

  //join the channel and connects to the server
  void _toggleJoinChannel() async {
    try {
      _channel = await _createChannel(channelName);
      await _channel.join();
      _log('Join channel success.');

      setState(() {});
    } catch (errorCode) {
      _log('Join channel error: ' + errorCode.toString());
    }
  }

  //create a Messaging channel and handle all its events
  Future<AgoraRtmChannel> _createChannel(String name) async {
    AgoraRtmChannel channel = await _client.createChannel(name);
    channel.onMemberJoined = (AgoraRtmMember member) {
      _log(
          "Member joined: " + member.userId + ', channel: ' + member.channelId);
    };
    channel.onMemberLeft = (AgoraRtmMember member) {
      _log("Member left: " + member.userId + ', channel: ' + member.channelId);
    };
    channel.onMessageReceived =
        (AgoraRtmMessage message, AgoraRtmMember member) {
      setState(() {
        _messages.add(Pair(member.userId, message.text));
      });
      _log("Channel msg: " + member.userId + ", msg: " + message.text);
    };
    return channel;
  }

  //client logged in
  void _toggleLogin() async {
    try {
      await _client.login(null, userName);
      _log('Login success: ' + userName);
      _toggleJoinChannel();
    } catch (errorCode) {
      _log('Login error: ' + errorCode.toString());
    }
  }

  //button to join the video which transfers the control to call page
  Widget _buildJoin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        new OutlineButton(
          child: Text('Join',
              style: TextStyle(fontSize: 18, color: Colors.deepPurple)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CallPage(channelName, role, userName),
              ),
            );
          },
        )
      ],
    );
  }

  //displays the channel  name
  Widget _buildChannelName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Channel Name : ' + channelName,
          style: TextStyle(
              fontSize: 18,
              color: Colors.deepPurple,
              decoration: TextDecoration.underline),
        ),
      ],
    );
  }

  //retrieve the message text
  Widget _buildSendChannelMessage() {
    return Row(children: <Widget>[
      new Expanded(
          child: new TextField(
              controller: _channelMessageController,
              decoration: InputDecoration(hintText: 'Enter message'))),
      new OutlineButton(
        child: Text('Send', style: textStyle),
        onPressed: _toggleSendChannelMessage,
      )
    ]);
  }

  //messages added to the list and sent to the server
  void _toggleSendChannelMessage() async {
    String text = _channelMessageController.text;
    if (text.isEmpty) {
      _log('Please input text to send.');
      return;
    }
    try {
      await _channel.sendMessage(AgoraRtmMessage.fromText(text));
      setState(() {
        _messages.add(Pair(userName, text));
      });
      _log(userName + ' : ' + text);
      _channelMessageController.clear();
    } catch (errorCode) {
      _log('Send channel message error: ' + errorCode.toString());
    }
  }

  static TextStyle textStyle =
      TextStyle(fontSize: 18, color: Colors.deepPurple);

  // Widget _buildInfoList() {
  //   return Expanded(
  //       child: Container(
  //           child: ListView.builder(
  //     itemExtent: 24,
  //     itemBuilder: (context, i) {
  //       return ListTile(
  //         contentPadding: const EdgeInsets.all(0.0),
  //         trailing: Text(_infoStrings[i]),
  //       );
  //     },
  //     itemCount: _infoStrings.length,
  //   )));
  // }

  //printing the messages onto the screen
  Widget _buildMessageList() {
    return Expanded(
        child: Container(
            child: ListView.builder(
      itemExtent: 24,
      itemBuilder: (context, i) {
        //if the sender is the current user then messages printed on right else left
        if (_messages[i].sender == userName) {
          return ListTile(
            contentPadding: const EdgeInsets.all(0.0),
            trailing: Text(_messages[i].sender + ' : ' + _messages[i].message),
          );
        } else {
          return ListTile(
            contentPadding: const EdgeInsets.all(0.0),
            leading: Text(_messages[i].sender + ' : ' + _messages[i].message),
          );
        }
      },
      itemCount: _messages.length,
    )));
  }

  //stores all the info and print them on console
  void _log(String info) {
    print(info);
    setState(() {
      // _infoStrings.insert(0, info);
      _infoStrings.add(info);
    });
  }
}

//custom Message Class to store sender and message text
class Pair {
  Pair(this.sender, this.message);

  final dynamic sender;
  final dynamic message;

  @override
  String toString() => 'Pair[$sender, $message]';
}
