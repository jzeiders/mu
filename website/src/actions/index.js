//Player
export const changeSong = id =>({type: 'CHANGE_SONG', id});
export const changePlayer = state => ({type: 'CHANGE_PLAYER', state});
export const setTrack = track => ({type: "SET_TRACK", track});
export const updateTime = time => ({type: "UPDATE_TIME", time});
export const setNext = id => ({type: "SET_NEXT",id});
export const setPlaylist = id => ({type: "SET_PLAYLIST",id});
export const popTrack = () => ({type: "POP_TRACK"});
export const setFuture = tracks => ({type: "SET_FUTURE", tracks});
export const setData = (data,id) => ({type: "SET_DATA", data, id});

//Login
export const setUsername = name => ({type: "SET_USERNAME",name});