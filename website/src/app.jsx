import React from 'react';
import PlayerContainer from "./player/playerContainer.jsx";
import {createStore} from 'redux'
import {Provider} from 'react-redux';
import reducers from './reducers'

const store = createStore(reducers,  window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__());

export default class App extends React.Component {
    constructor(props) {
        super(props)
    }
    render() {
        return (
            <Provider store={store}>
                <div>
                    <h1>
                        Spotify App
                    </h1>
                    <PlayerContainer/>
                </div>
            </Provider>
        )
    }
}
