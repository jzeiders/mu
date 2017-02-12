import React from 'react';
import styles from './header.scss'

export default class Header extends React.Component{
    constructor(props){
        super(props);
    }
    render(){
        return (
            <div className={styles.headerBar}>
            <h3>{this.props.login.username || "MU"}</h3>
            </div>
        )
    }
}