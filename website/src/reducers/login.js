const initialState = {
    username : null
}

export default function login(state = initialState, action){
    switch (action.type){
        case "SET_USERNAME":
            return (
                Object.assign({}, state, {
                    username: action.name
                })
            )
        default:
            return state;
    }
}