import React from 'react';
import PlayerContainer from "./player/playerContainer.jsx";
import LoginContainer from "./login/loginContainer.jsx";
import Viz from "./viz/viz.jsx";
import Header from "./header/header.jsx";
import {bindActionCreators} from 'redux';
import {Provider, connect} from 'react-redux';
import styles from "./index.scss";
import * as actionCons from "./actions";


class App extends React.Component{
    constructor(props){
        super(props)
    }
    render(){
        return (
        <div id="main">
            <Header login={this.props.login}> </Header>
            <LoginContainer login={this.props.login} actions={this.props.actions}></LoginContainer>
            <Viz login={this.props.login} viz={this.props.viz}> </Viz>
            <PlayerContainer login={this.props.login} player={this.props.player} actions={this.props.actions}/>
        </div>
        )
    }
}

const mapStateToProps = (state, ownProps) => ({
  player: state.player,
  login: state.login,
  viz: state.viz
})

const mapDispatchToProps = dispatch => ({
    actions: bindActionCreators(actionCons, dispatch)
})

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(App)