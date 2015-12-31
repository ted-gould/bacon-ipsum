import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3

MainView {
	width: units.gu(40)
	height: units.gu(70)

	automaticOrientation: true
	applicationName: "bacon-ipsum.ted"

	PageStack {
		id: pageStack
		Component.onCompleted: pageStack.push(root)

		Page {
			id: root
			title: qsTr("Bacon Ipsum")

			Column {
				anchors.fill: parent
				anchors.leftMargin: units.gu(1.5)
				anchors.rightMargin: units.gu(1.5)

				spacing: units.gu(0.75)

				TextArea {
					anchors {
						left: parent.left
						right: parent.right
					}

					id: bacontext
					autoSize: true
					placeholderText: qsTr("Bacon")
					readOnly: true
					maximumLineCount: 20
					selectByMouse: false
				}

				Button {
					anchors {
						left: parent.left
						right: parent.right
					}

					text: "Copy to Clipboard"
					onClicked: {
						bacontext.selectAll()
						bacontext.copy()
						bacontext.deselect()
					}
				}

				Button {
					anchors {
						left: parent.left
						right: parent.right
					}

					text: "Share"
					onClicked: {
						pageStack.push(picker, {text: bacontext.text})
					}
				}
			} // Column

			Component.onCompleted: {
					request('https://baconipsum.com/api/?type=meat-and-filler', function (o) {
							
							// translate response into object
							var d = eval(o.responseText);

							// access elements inside json object with dot notation
							if (d) {
								bacontext.text = d[0]
							}
						});
			}

			function request(url, callback) {
				var xhr = new XMLHttpRequest();
				xhr.onreadystatechange = (function(myxhr) {
					return function() {
						callback(myxhr);
					}
				})(xhr);
				xhr.open('GET', url, true);
				xhr.send('');
			}
		} // Flickable

		Page {
			id: picker
			visible: false
			property var text

			Component {
				id: resultComponent
				ContentItem {}
			}

			ContentPeerPicker {
				id: peerPicker

				visible: parent.visible
				contentType: ContentType.Text
				handler: ContentHandler.Share

				onCancelPressed: {
					print ("onCancelPressed");
					pageStack.pop();
				}

				onPeerSelected: {
					print ("onPeerSelected: " + peer.name);
					print ("sending text: " + picker.text);
					var request = peer.request();
					request.items = [ resultComponent.createObject(root, {"text": picker.text}) ];
					request.state = ContentTransfer.Charged;
					pageStack.pop();
				}
			}
		}
	}

} // MainView
