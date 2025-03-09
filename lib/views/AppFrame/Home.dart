import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        RecordDay()
        // Card(
        //   elevation: 1,
        //   color: Theme.of(context).colorScheme.secondary,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(8)
        //   ),
        //   child: Padding(
        //     padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
        //     child: Container(
        //       width: 100,
        //       child: Column(
        //         mainAxisSize: MainAxisSize.max,
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [

        //         ]
        //       )
        //     ),
        //   )
        // )
      ],
    );
  }
}

class RecordDay extends StatelessWidget {
  const RecordDay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: Theme.of(context).colorScheme.secondary,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
            ),
            shape: BoxShape.rectangle,
          ),
          alignment: AlignmentDirectional(0, -1),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RecordDayHeader(),
              Divider(
                height: 5,
              ),
              RecordDayBody(),
            ],
          ),
        ),
      ),
    );
  }
}

class RecordDayHeader extends StatelessWidget {
  const RecordDayHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
      child: Container(
        height: 20,
        decoration: BoxDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: MediaQuery.sizeOf(context).width * 0.3,
              decoration: BoxDecoration(),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                    child: Text(
                      '7/12'
                    ),
                  ),
                  Text(
                    'Sat',
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.sizeOf(context).width * 0.32,
              height: 100,
              decoration: BoxDecoration(),
              alignment: AlignmentDirectional(1, 0),
              child: Text(
                '+400.00',
              ),
            ),
            Container(
              width: MediaQuery.sizeOf(context).width * 0.32,
              height: 100,
              decoration: BoxDecoration(),
              alignment: AlignmentDirectional(1, 0),
              child: Text(
                '-200.00',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordDayBody extends StatelessWidget {
  const RecordDayBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: [
        Align(
          alignment: AlignmentDirectional(0, 0),
          child: Container(
            decoration: BoxDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width:
                            MediaQuery.sizeOf(context).width * 0.63,
                        height: 50,
                        decoration: BoxDecoration(),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0, 0, 10, 0),
                              child: Icon(
                                Icons.lunch_dining,
                                color: Color(0xFFFFD700),
                                size: 30,
                              ),
                            ),
                            Text(
                              'Lunch'
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {},
                        child: Container(
                          width:
                              MediaQuery.sizeOf(context).width * 0.32,
                          height: 50,
                          decoration: BoxDecoration(),
                          alignment: AlignmentDirectional(1, 0),
                          child: Text(
                            '-100.00',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width:
                            MediaQuery.sizeOf(context).width * 0.05,
                        decoration: BoxDecoration(),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            decoration: BoxDecoration(),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: MediaQuery.sizeOf(context)
                                          .width *
                                      0.58,
                                  decoration: BoxDecoration(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional
                                            .fromSTEB(0, 0, 10, 0),
                                        child: Icon(
                                          Icons
                                              .account_balance_wallet_rounded,
                                          color: Color(0xFF0035FF),
                                          size: 24,
                                        ),
                                      ),
                                      Text(
                                        'Tng E-Wallet'
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.sizeOf(context)
                                          .width *
                                      0.32,
                                  decoration: BoxDecoration(),
                                  child: Text(
                                    '500.00',
                                    textAlign: TextAlign.end
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: MediaQuery.sizeOf(context)
                                          .width *
                                      0.58,
                                  decoration: BoxDecoration(),
                                  alignment:
                                      AlignmentDirectional(1, 0),
                                  child: Text(
                                    'Balance: '
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.sizeOf(context)
                                          .width *
                                      0.32,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(0),
                                      topLeft: Radius.circular(0),
                                      topRight: Radius.circular(0),
                                    ),
                                  ),
                                  child: Align(
                                    alignment:
                                        AlignmentDirectional(1, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Divider(
                                          height: 5,
                                        ),
                                        Text(
                                          '400.00',
                                          textAlign: TextAlign.end
                                        ),
                                        Divider(
                                          height: 2,
                                        ),
                                        Divider(
                                          height: 2,
                                        ),
                                      ],
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
              ],
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional(0, 0),
          child: Container(
            height: 45,
            decoration: BoxDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: AlignmentDirectional(0, -1),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.63,
                    height: 50,
                    decoration: BoxDecoration(),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0, 0, 10, 0),
                          child: Icon(
                            Icons.dinner_dining,
                            color: Color(0xFFFFD700),
                            size: 30,
                          ),
                        ),
                        Text(
                          'Dinner',
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.32,
                  height: 50,
                  decoration: BoxDecoration(),
                  alignment: AlignmentDirectional(1, 0),
                  child: Text(
                    '-100.00',
                      style: TextStyle(
                      color: Theme.of(context).colorScheme.error
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
