﻿var ServiceChatSID = function (EWinURL) {
    var WebHub;
    var currentState = 4;  //0=connecting, 1=connected, 2=reconnecting, 4=disconnected
    var onNotify;
    var onReconnected;
    var onReconnecting;
    var onConnected;
    var onDisconnect;
    var onStateChange;
    const CONNECTING = 0;
    const CONNECTED = 1;
    const RECONNECTING = 2;
    const DISCONNECTED = 4;

    this.SetToken = function (newToken) {
        Token = newToken;
    };

    this.HeartBeat = function (echo, cb) {
        WebHub.invoke("HeartBeat", echo).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.LogoutConnection = function (SID, cb) {
        WebHub.invoke("LogoutConnectionSID", SID).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.CreateMedia = function (SID, MediaType, ExtName, cb) {
        WebHub.invoke("CreateMedia", SID, MediaType, ExtName).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.SetMediaChunk = function (SID, MediaId, ChunkIndex, ChunkContentB64, cb) {
        WebHub.invoke("SetMediaChunk", SID, MediaId, ChunkIndex, ChunkContentB64).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.CloseAndSendMedia = function (SID, RoomID, MediaId, cb) {
        WebHub.invoke("CloseAndSendMedia", SID, RoomID, MediaId).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.UpdateConnection = function (SID, cb) {
        WebHub.invoke("UpdateConnectionSID", SID).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.GetRoomPageMessage = function (SID, Page, cb) {
        WebHub.invoke("GetRoomPageMessageSID", SID, Page).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.GetRoomPageCount = function (SID, cb) {
        WebHub.invoke("GetRoomPageCountSID", SID).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.GetRoom = function (SID, cb) {
        WebHub.invoke("GetRoomSID", SID).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.JoinRoom = function (SID, cb) {
        WebHub.invoke("JoinRoomSID", SID).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.CreateRoom = function (SID, cb) {
        WebHub.invoke("CreateRoomSID", SID).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.AddTextMessage = function (SID, RoomID, MsgGUID, Text, cb) {
        WebHub.invoke("AddTextMessageSID", SID, RoomID, MsgGUID, Text).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.handleNotify = function (handle) {
        onNotify = handle;
    };

    this.handleReconnected = function (handle) {
        onReconnected = handle;
    };

    this.handleReconnecting = function (handle) {
        onReconnecting = handle;
    };

    this.handleConnected = function (handle) {
        onConnected = handle;
    };

    this.handleDisconnect = function (handle) {
        onDisconnect = handle;
    };

    this.handleStateChange = function (handle) {
        onStateChange = handle;
    };

    this.state = function () {
        return currentState;
    };

    this.initializeConnection = function () {
        function connectServer(c) {
            c.start({ withCredentials: false })
                .done(function () {
                    if (onConnected != null)
                        onConnected();
                })
                .fail(function (error) {
                    if (onDisconnect != null) {
                        onDisconnect();
                    }
                });

        }

        var conn = $.hubConnection();

        conn.url = EWinURL + "/signalr";

        WebHub = conn.createHubProxy("ServiceChatHub");
        WebHub.on("notify", notify);

        conn.disconnected(function () {
            setTimeout(function () {
                connectServer(conn);
            }, 1000);
        });

        conn.stateChanged(function (state) {
            //state.oldState
            currentState = state.newState;

            if (onStateChange != null)
                onStateChange(state.newState, state.oldState);
        });

        conn.reconnected(function () {
            if (onReconnected != null)
                onReconnected();
        });

        conn.reconnecting(function () {
            if (onReconnecting != null)
                onReconnecting();
        });

        connectServer(conn);
    };

    function getJSON(text) {
        var obj = JSON.parse(text);

        if (obj) {
            if (obj.hasOwnProperty('d')) {
                return obj.d;
            } else {
                return obj;
            }
        }
    }

    function notify(o) {
        if (o != null) {
            if (onNotify != null)
                onNotify(o);
        }
    }
}