import React from 'react';
import styles from './login.scss'
import Login from './login.jsx'

export default class LoginContainer extends React.Component {
    constructor(props){
        super(props)
    }
    handleLogin(name){
        this.props.actions.setUsername(name);
    }
    render(){
        if(!this.props.login.username)
        return ( 
           <Login className={styles.form} doLogin={this.handleLogin.bind(this)}> </Login>
        )
        else 
            return null;
    }
}