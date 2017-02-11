import React from 'react';
import Player from './player.jsx'

export default class PlayerContainer extends React.Component {
    constructor(props){
        super(props)
    }
    render(){
        return (
            <Player/>
        )
    }
}