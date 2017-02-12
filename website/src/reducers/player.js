const initialState = {
	id: "NULL",
    playing: false,
    track: {
        length: 100000000,
        artist: null,
        title: null,
        art_url: null
    },
    time: 0,
    next: null,
    playlist: 'relaxed',
    future: [
        "253373096",
        "114238860"
    ]
}

export default function player(state = initialState, action) {
	switch (action.type) {
		case "CHANGE_SONG":
			return (
				Object.assign({}, state, {
					id: action.id
				}));
		case "CHANGE_PLAYER":
			return (
				Object.assign({}, state, {
					playing: action.state
				}));
        case "SET_TRACK":
            return (
                Object.assign({},state, {
                    track: action.track 
                }));
        case "UPDATE_TIME":
             return (
                Object.assign({},state, {
                    time: action.time 
                }));
        case "SET_NEXT":
            return (
                Object.assign({},state,{
                    next: action.id
                })
            )
        case "SET_PLAYLIST":
            return (
                Object.assign({},state, {
                    playlist: action.id
                })
            )
        case "SET_FUTURE":
            return (
                Object.assign({},state, {
                    future: action.tracks
                })
            )
        case "POP_TRACK":
            return (
                Object.assign({},state,{
                    future: state.future.slice(1)
                })
            )
        case "SET_DATA":
            state.future[action.id] = {song_id: state.future.song_id, data: action.data}
            return (
                Object.assign({},state,{
                    future: state.future
                })
            )
		default:
			return state;
	}
}
