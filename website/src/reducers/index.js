
import { combineReducers } from 'redux';
import player from './player';
import visualizer from './visualizer';
import login from './login';

const rootReducer = combineReducers({
  player,
  login,
  visualizer
})

export default rootReducer;