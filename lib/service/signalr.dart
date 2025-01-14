import 'package:signalr_netcore/signalr_client.dart';

late HubConnection hubConnection;

void connectSignalR(String receiptId) {
  hubConnection = HubConnectionBuilder()
      .withUrl("http://localhost:5132/notificationHub")
      .build();

  hubConnection.onclose((error) => print("Connection Closed"));

  // Khi có cập nhật
  hubConnection.on("StatusUpdated", (arguments) {
    final data = arguments![0] as Map<String, dynamic>;
    print("Status updated for ReceiptId: ${data['receiptId']}");
    // Cập nhật giao diện tại đây
  });

  hubConnection.start().then((_) {
    hubConnection.invoke("JoinGroup", args: [receiptId]);
  }).catchError((err) {
    print("SignalR connection error: $err");
  });
}

void disconnectSignalR(String receiptId) {
  hubConnection.invoke("LeaveGroup", args: [receiptId]);
  hubConnection.stop();
}
