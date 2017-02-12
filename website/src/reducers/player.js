import {CHANGE_SONG} from '../actions'

const initialState = [
    {
        text: 'Use Redux',
        completed: false,
        id: 0
    }
]

export default function player(state = {}, action) {
    switch (action.type) {
        case CHANGE_SONG:
            return [
                {
                    id: Math.random()
                },
                ...state
            ]
        default:
            return state;
    }
}