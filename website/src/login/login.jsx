import React from 'react';
import styles from './login.scss'
// const Form = mui.react.Form,
//  Input = mui.react.Input,
// Textarea= mui.react.Textarea,
// Button= mui.react.Button;

import { Form, Input, Textarea, Button } from 'muicss/react';

export default class Login extends React.Component {
    constructor(props){
        super(props)
        this.state ={};
        this.login = this.login.bind(this);
        this.handleChange = this.handleChange.bind(this);
    }
    handleChange(event) {
        this.setState({value: event.target.value});
    }

    login(event){
        console.log(this.state.value);
        event.preventDefault();
        this.props.doLogin(this.state.value)
    }
   render() {
    return (
      <Form className={styles.formItems}>
        <legend>Please Login</legend>
        <Input hint="Username" value={this.state.value} onChange={this.handleChange} />
        <Button onClick={this.login} color="primary">Login</Button>
      </Form>
    );
  }
}