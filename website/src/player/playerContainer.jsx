import React from 'react';
import Player from './player.jsx';
import axios from 'axios';
import SC from 'soundcloud';

const changeUrl = "ws://mu-websocket-server.herokuapp.com/song_name";
const trackUrl = "https://hackpoly-mu.herokuapp.com/playlist"

export default class PlayerContainer extends React.Component {
    constructor(props) {
        super(props)
        this.state = {samServer: new WebSocket(changeUrl), started: false};

    }
    componentWillMount(){
     
    }
    componentDidUpdate(prevProps, prevState){
        if(prevProps.login.username == null && !this.state.started){
            this.startTrack();
            this.setState({started: true});
        }
    }
    startTrack(){
        SC.initialize({
            client_id: 'fDoItMDbsbZz8dY16ZzARCZmzgHBPotA'
        });
        this.getTracks().then((data) => {
            this.stream(this.props.player.future[0].song_id);
            this.getTrackInfo(this.props.player.future[0].song_id).then((data)=>{
                this.props.actions.setTrack(data);
            });
            this.props.actions.popTrack();
        });
    }
    getTrackInfo(id){
        return SC.get('/tracks/'+id).then((res) => {
            let track = {
                length: res.duration,
                title: res.title,
                art_url: res.artwork_url
            }
            return track;
            console.log(res);
        }).catch((err) => {
            console.log(err);
        })
    }
    handlePlaylist(num){
        console.log(num + " NUM");
        this.props.actions.setPlaylist(num);
        this.getTracks(num);
    }
    sendTrack(id){
        let item = JSON.stringify({track_id: id, username: this.props.login.username});
        this.state.samServer.send(item);
    }
    setCurrentTime(){
        var time = this.state.sc.currentTime();
        this.props.actions.updateTime(time);
    }
    finishTrack(trackID){
        this.sendTrack(trackID);
        clearInterval(this.state.timer);
        if(this.props.player.future[0]){
            this.stream(this.props.player.future[0].song_id);
            this.props.actions.setTrack(this.props.player.future[0].data["_result"]);
            this.props.actions.popTrack();
        }
        this.props.actions.updateTime(null);
    }
    endJump(){
        this.state.sc.seek(this.props.player.track.length);
    }
    stream(trackID){
        SC.stream('/tracks/'+trackID).then((player) => {
            player.play();
            this.setState({sc: player});
            this.props.actions.changePlayer(true);
            let timer = setInterval(this.setCurrentTime.bind(this), 100);
            this.setState({timer: time});
            player.on("finish", () => {
                this.finishTrack(trackID);

            })
            console.log(store.getState());
            this.props.actions.changeSong(trackID);
        })
    }
    pauseHandler(event){
        console.log(this);
        if(!this.props.player.playing){     
            this.props.actions.changePlayer(true);
            this.state.sc.play();
        }
        else {
            console.log("way" )
            this.props.actions.changePlayer(false);
            this.state.sc.pause();
        }
    }

    getTracks(num){
        return axios.get(trackUrl, {
            params: {
                classification: num || this.props.player.playlist,
                username: this.props.login.username
            }
        }).then((data)=>{
           return data.data.playlist.map((v) => ({
                song_id: v["song-id"],
                data: this.getTrackInfo(v["song-id"])
            }));
        }).then((promises)=> {
             return Promise.all(promises);
        }).then((data)=>{
            return this.props.actions.setFuture(data);
        }).catch((err) => {
            console.log(err);
        });
    }
    render() {
        if(this.props.login.username)
        return (<Player endJump={this.endJump.bind(this)} handlePlaylist={this.handlePlaylist.bind(this)} time={this.props.player.time} track={this.props.player.track} pauseState={this.props.player.playing} pauseHandler={this.pauseHandler.bind(this)}/>)
        return null;
    }
}