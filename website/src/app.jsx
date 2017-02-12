import React from 'react';
import PlayerContainer from "./player/playerContainer.jsx";
import { Provider } from 'react-redux';
import reducer from './reducers'



export default class App extends React.Component {
    constructor(props) {
        super(props)
    }
    render() {
        return (
            <Provider>
                <h1>
                    Spotify App
                </h1>
                <PlayerContainer/>
            </Provider>
        )
    }
}