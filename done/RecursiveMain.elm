module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Random exposing (Generator)
import Random.Extra


type Color
    = White
    | Red
    | Yellow
    | Blue



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    { grid : Grid }


type Grid
    = Empty
    | Done Color
    | TwoBySide Grid Grid
    | TwoStacked Grid Grid


init : () -> ( Model, Cmd Msg )
init flags =
    ( { grid = Empty }, generateGrid 9 )



-- UPDATE


type Msg
    = NoOp
    | NewGrid Grid


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NewGrid grid ->
            ( { model | grid = grid }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.h1 [] [ Html.text "Hello LambdUp!" ]
        , viewGrid model.grid
        ]


viewGrid : Grid -> Html Msg
viewGrid grid =
    Html.div
        [ Attr.class "grid" ]
        [ viewRecursiveGrid grid ]


viewRecursiveGrid : Grid -> Html Msg
viewRecursiveGrid grid =
    case grid of
        TwoBySide first second ->
            Html.div [ Attr.class "grid--two-by-side" ]
                [ viewRecursiveGrid first
                , viewRecursiveGrid second
                ]

        TwoStacked first second ->
            Html.div [ Attr.class "grid--two-stacked" ]
                [ viewRecursiveGrid first
                , viewRecursiveGrid second
                ]

        Done color ->
            let
                modifier =
                    String.toLower (colorToString color)
            in
            Html.div
                [ Attr.class "grid--cell__recursive"
                , Attr.class ("grid--cell__" ++ modifier)
                ]
                []

        Empty ->
            Html.text ""


colorToString : Color -> String
colorToString color =
    case color of
        White ->
            "white"

        Red ->
            "red"

        Yellow ->
            "yellow"

        Blue ->
            "blue"


generateGrid : Int -> Cmd Msg
generateGrid depth =
    Random.generate NewGrid (gridGenerator depth)


gridGenerator : Int -> Generator Grid
gridGenerator current =
    if current == 0 then
        Random.map Done randomColor
    else
        Random.Extra.frequency
            ( 1
            , Random.map2
                TwoStacked
                (gridGenerator (current - 1))
                (gridGenerator (current - 1))
            )
            [ ( 1
              , Random.map2
                    TwoBySide
                    (gridGenerator (current - 1))
                    (gridGenerator (current - 1))
              )
            ]


randomColor : Generator Color
randomColor =
    Random.weighted
        ( 10, White )
        [ ( 1, Red )
        , ( 1, Yellow )
        , ( 1, Blue )
        ]
