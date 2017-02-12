import React from 'react';
import styles from './player.scss';
import {SegmentedControl} from 'segmented-control';

export default class Player extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            mood: "relaxed"
        }
        this.handleChange = this
            .handleChange
            .bind(this);
        this.handleSeg = this
            .handleSeg
            .bind(this);
    }
    handleChange(e) {
        this.setState({selectedValue: e});
        this
            .props
            .handlePlaylist(e);
        e.preventDefault();
    }
    handleSeg(e){
        this.setState({mood: e.target.value});
        this.props.handlePlaylist(e.target.value);
    }
    render() {
        return (
            <div>
                <div className = {styles.tabs}>
                <form className={styles.segmentedControl} style={{width: '100%', color: 'darkorange'}}>
                    <input checked={this.state.mood == "relaxed"} onChange={this.handleSeg} type="radio" name="sc-3" id="sc-3-2-1" value="relaxed"/>
                    <input checked={this.state.mood == "focused"} onChange={this.handleSeg} type="radio" name="sc-3" id="sc-3-2-2" value="focused"/>
                    <input checked={this.state.mood == "hyped"} onChange={this.handleSeg} type="radio" name="sc-3" id="sc-3-2-3" value="hyped"/>
                    <label htmlFor="sc-3-2-1" value="1" data-value="Relaxed">Relaxed</label>
                    <label htmlFor="sc-3-2-2" value="1" data-value="Focused">Focused</label>
                    <label htmlFor="sc-3-2-3" value="1" data-value="Hyped">Hyped</label>
                </form>
                </div>
                <div className={styles.playerBox}>
                    <img id="art" src={this.props.track.art_url}/>
                    <div className={styles.bar}>
                        <div className={styles.titleBox}>
                            <button className={styles.btn} onClick={this.props.pauseHandler}>
                                <i
                                    className={!this.props.pauseState
                                    ? "fa fa-play"
                                    : "fa fa-pause"}></i>
                            </button>
                            <h5>
                                {this.props.track.title}
                            </h5>
                            <button id="skip" className={styles.skip} onClick={this.props.endJump}> 
                                SKIP <i className={"fa fa-arrow-right"}></i>
                            </button>

                        </div>
                        <progress id='time' max={this.props.track.length} value={this.props.time}></progress>
                    </div>
                </div>
            </div>
        )
    }
}

Player.PropTypes = {
    track: React.PropTypes.object,
    pauseState: React.PropTypes.bool,
    pauseHandler: React.PropTypes.func,
    length: React.PropTypes.number
}