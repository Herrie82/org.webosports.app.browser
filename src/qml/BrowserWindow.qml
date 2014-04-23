/*
 * Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies)
 * Copyright (C) 2010 University of Szeged
 * Copyright (c) 2012 Hewlett-Packard Development Company, L.P.
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import QtQuick 2.0
import QtWebKit 3.0
import QtWebKit.experimental 1.0

import LunaNext.Common 0.1

Rectangle {
    id: root
    // Do not define anchors or an initial size here! This would mess up with QSGView::SizeRootObjectToView.

    property alias webview: webView
    color: "#333"

    signal pageTitleChanged(string title)
    signal newWindow(string url)

    function load(address) {
        webView.url = address
        webView.forceActiveFocus()
    }

    function reload() {
        webView.reload()
        webView.forceActiveFocus()
    }

    function focusAddressBar() {
        addressLine.forceActiveFocus()
        addressLine.selectAll()
    }

    function toggleFind() {
        findBar.toggle()
    }

    focus: true
    Keys.onPressed: {
        console.log("Key pressed: key=" + event.key + " text=" + event.text);
        event.accepted = false;
    }

    NavigationBar {
        id: navigationBar

        webView: webView

        height: Units.gu(4)
        z: webView.z + 1
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

    }

    FindBar {
        id: findBar
        webView: webView
        navigationBar: navigationBar
    }

    WebView {
        id: webView
        clip: false

        anchors {
            top: findBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        onTitleChanged: pageTitleChanged(title)
        onUrlChanged: {
            navigationBar.currentUrl = webView.url

            if (options.printLoadedUrls)
                console.log("WebView url changed:", webView.url.toString());
        }

        onLoadingChanged: {
            if (!loading && loadRequest.status == WebView.LoadFailedStatus)
                webView.loadHtml("Failed to load " + loadRequest.url, "", loadRequest.url)
        }

        experimental.preferences.fullScreenEnabled: true
        experimental.preferences.webGLEnabled: true
        experimental.preferences.webAudioEnabled: true
        experimental.itemSelector: ItemSelector { }
        experimental.alertDialog: AlertDialog { }
        experimental.confirmDialog: ConfirmDialog { }
        experimental.promptDialog: PromptDialog { }
        experimental.authenticationDialog: AuthenticationDialog { }
        experimental.proxyAuthenticationDialog: ProxyAuthenticationDialog { }
        experimental.filePicker: FilePicker { }
        experimental.preferences.developerExtrasEnabled: false
        experimental.databaseQuotaDialog: Item {
            Timer {
                interval: 1
                running: true
                onTriggered: {
                    var size = model.expectedUsage / 1024 / 1024
                    console.log("Creating database '" + model.displayName + "' of size " + size.toFixed(2) + " MB for " + model.origin.scheme + "://" + model.origin.host + ":" + model.origin.port)
                    model.accept(model.expectedUsage)
                }
            }
        }
        experimental.colorChooser: ColorChooser { }
        experimental.onEnterFullScreenRequested : {
            navigationBar.visible = false;
            Window.showFullScreen();
        }
        experimental.onExitFullScreenRequested : {
            Window.showNormal();
            navigationBar.visible = true;
        }
    }

    ScrollIndicator {
        flickableItem: webView
    }
}
