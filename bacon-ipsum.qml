/*
 * Copyright © 2015 Canonical Ltd
 *
 * This file is part of Bacon Ipsum
 *
 * Bacon Ipsum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Bacon Ipsum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3
import Ubuntu.Components.ListItems 1.3

MainView {
	width: units.gu(40)
	height: units.gu(70)

	automaticOrientation: true
	applicationName: "bacon-ipsum.ted"

	PageStack {
		id: pageStack
		Component.onCompleted: pageStack.push(root)
	}

	Page {
		id: root
		title: i18n.tr("Bacon Ipsum")

		head.actions: [
			Action {
				id: settings
				text: i18n.tr("Settings")
				iconName: "settings"
				onTriggered: {
					pageStack.push(settingsPage)
				}
			},
			Action {
				id: refresh
				text: i18n.tr("Refresh")
				iconName: "reload"
				onTriggered: {
					root.baconRefresh()
				}
			}
		]

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
				placeholderText: i18n.tr("Bacon")
				readOnly: true
				maximumLineCount: 20
				selectByMouse: false
			}

			Button {
				anchors {
					left: parent.left
					right: parent.right
				}

				text: i18n.tr("Copy to Clipboard")
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
			baconRefresh()
		}

		function baconRefresh() {
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
	} // Page

	Page {
		id: picker
		property var text
		visible: false
		header: null

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

	Page {
		id: settingsPage
		title: i18n.tr("Settings")
		visible: false

		Column {
			anchors.fill: parent

			/* Added a selector, but turns out none of these have
			   an API :-( */
			/*
			Header {
				text: i18n.tr("Ipsum Type:")
			}
			ItemSelector {
				model: [
					i18n.tr("Bacon"),
					i18n.tr("Fish"),
					i18n.tr("Veggie"),
					i18n.tr("Traditional")
				]
			}

			Divider {}
			*/
		}
	}

} // MainView
