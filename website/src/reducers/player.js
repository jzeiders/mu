import {CHANGE_SONG} from 

const initialState = [
    {
        text: 'Use Redux',
        completed: false,
        id: 0
    }
]

export default function todos(state = initialState, action) {
    switch (action.type) {
        case CHANGE_SONG:
            return [
                {
                    id: Math.random()
                },
                ...state
        ]
    }
}