import React from 'react';
import styles from './viz.scss';
import ReactSmoothiee from "react-smoothie";
import smoothie from 'smoothie';

const ws = "wss://mu-websocket-server.herokuapp.com/raw_data"

export default class Viz extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            width: 1200,
            height: 400,
            chart: null
        }
    }
    componentDidMount(){
    }
    componentDidUpdate(prevProps, prevState) {
        if (prevProps.login.username == null) {

            console.log("MOUNTED")
            console.log(this.chart);
            if (!this.smoothie) 
                this.smoothie = new smoothie.SmoothieChart({strokeStyle:'transparent',sharpLines:true,scaleSmoothing:0.1,maxValue:1,minValue:0});
            
            if (this.canvas) {
                this
                    .smoothie
                    .streamTo(this.canvas, 0);
                var alpha = this
                    .addTimeSeries({}, {
                        strokeStyle: 'rgba(254,247 ,120 , 1)',
                        lineWidth: 2
                    });
                var beta = this
                    .addTimeSeries({}, {
                        strokeStyle: 'rgba(106, 167, 134, 1)',
                        lineWidth: 2
                    });
                var gamma = this
                    .addTimeSeries({}, {
                        strokeStyle: 'rgba(53, 194, 209, 1)',
                        lineWidth: 2
                    });
                var delta = this
                    .addTimeSeries({}, {
                        strokeStyle: 'rgba(217, 80, 138, 1)',
                        lineWidth: 2
                    });
                var theta = this
                    .addTimeSeries({}, {
                        strokeStyle: 'rgba(254, 149, 7, 1)',
                        lineWidth: 2
                    });
                this.rawData = new WebSocket(ws);
                this.rawData.addEventListener('message', function (event) {
                    if(event.data != "hi"){
                        var data = JSON.parse(event.data);
                        console.log(data);
                        var time = new Date().getTime();
                        if(data.alpha)
                        alpha.append(time,data.alpha);
                        if(data.beta)
                        beta.append(time,data.beta);
                        if(data.gamma)
                        gamma.append(time,data.gamma);
                        if(data.delta)
                        delta.append(time,data.delta);
                        if(data.theta)
                        theta.append(time,data.theta);
                    }
                });
            }
        }
    }
    addTimeSeries(tsOpts, addOpts) {
        var ts = new smoothie.TimeSeries(tsOpts);
        this
            .smoothie
            .addTimeSeries(ts, addOpts);
        return ts;
    }
    componentWillUnmount() {
        clearInterval(this.dataGenerator);
        this
            .smoothie
            .stop();
        this.smoothie = undefined;
    }

    render() {
        if (this.props.login.username) 
            return (
                <div className={styles.chart}>
                    <canvas
                        ref={(canv) => {
                        this.canvas = canv
                    }}
                        width={this.state.width}
                        height={this.state.height}/>
                </div>
            )
        return null;
    }
}