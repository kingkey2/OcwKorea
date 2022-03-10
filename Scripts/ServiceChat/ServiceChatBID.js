var ServiceChatBID = function (EWinURL) {
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

    this.HeartBeat = function (echo, cb) {
        WebHub.invoke("HeartBeat", echo).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.LogoutConnection = function (BID, cb) {
        WebHub.invoke("LogoutConnectionBID", BID).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.CreateMedia = function (BID, MediaType, ExtName, cb) {
        WebHub.invoke("CreateMediaBID", BID, MediaType, ExtName).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.SetMediaChunk = function (BID, MediaId, ChunkIndex, ChunkContentB64, cb) {
        WebHub.invoke("SetMediaChunkBID", BID, MediaId, ChunkIndex, ChunkContentB64).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.CloseAndSendMedia = function (BID, RoomID, MediaId, cb) {
        WebHub.invoke("CloseAndSendMediaBID", BID, RoomID, MediaId).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.UpdateConnection = function (BID, cb) {
        WebHub.invoke("UpdateConnectionBID", BID).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.GetRoomPageMessage = function (BID, RoomID, Page, cb) {
        WebHub.invoke("GetRoomPageMessageBID", BID, RoomID, Page).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.GetRoomPageCount = function (BID, RoomID, cb) {
        WebHub.invoke("GetRoomPageCountBID", BID, RoomID).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.ListTakeRoom = function (BID, cb) {
        WebHub.invoke("ListTakeRoomBID", BID).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.ListNewRoom = function (BID, cb) {
        WebHub.invoke("ListNewRoomBID", BID).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.CloseRoom = function (BID, RoomID, cb) {
        WebHub.invoke("CloseRoomBID", BID, RoomID).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.TakeRoom = function (BID, RoomID, cb) {
        WebHub.invoke("TakeRoomBID", BID, RoomID).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.GetRoom = function (BID, RoomID, cb) {
        WebHub.invoke("GetRoomBID", BID, RoomID).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.JoinRoom = function (BID, RoomID, cb) {
        WebHub.invoke("JoinRoomBID", BID, RoomID).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.JoinMultiRoom = function (BID, RoomIDArray, cb) {
        WebHub.invoke("JoinMultiRoomBID", BID, RoomIDArray).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.AddTextMessage = function (BID, RoomID, MsgGUID, Text, cb) {
        WebHub.invoke("AddTextMessageBID", BID, RoomID, MsgGUID, Text).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
    };

    this.RemoveSeveiceAccountByRoomID = function (BID, RoomID, cb) {
        WebHub.invoke("RemoveSeveiceAccountByRoomID", BID, RoomID).done(function (o) {
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

    this.CheckHasRoom = function (BID, UserAccountID, LoginAccount, cb) {
        WebHub.invoke("CheckHasRoom", BID, UserAccountID, LoginAccount).done(function (o) {
            if (cb)
                cb(true, o);
        }).fail(function (err) {
            if (cb)
                cb(false, err);
        });
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