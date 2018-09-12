module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick)
import Random exposing (Generator)
import Random.Extra


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


type alias Grid =
    { rows : List Row }


type alias Row =
    { height : Float
    , cells : List Cell
    }


type alias Cell =
    { width : Float
    , color : Color
    }


type Color
    = White
    | Red
    | Yellow
    | Blue


init : () -> ( Model, Cmd Msg )
init flags =
    ( initialModel, generateGrid 4 7 )


initialModel : Model
initialModel =
    { grid =
        { rows =
            [ { height = 30.0
              , cells =
                    [ { width = 55.0, color = White }
                    , { width = 15.0, color = Yellow }
                    , { width = 10.0, color = White }
                    , { width = 20.0, color = White }
                    ]
              }
            , { height = 40.0
              , cells =
                    [ { width = 35.0, color = White }
                    , { width = 15.0, color = Red }
                    , { width = 50.0, color = White }
                    ]
              }
            , { height = 30.0
              , cells =
                    [ { width = 30.0, color = Red }
                    , { width = 55.0, color = White }
                    , { width = 15.0, color = Blue }
                    ]
              }
            ]
        }
    }



-- UPDATE


type Msg
    = NoOp
    | NewGrid Grid
    | RefreshGrid


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NewGrid grid ->
            ( { model | grid = grid }, Cmd.none )

        RefreshGrid ->
            ( model, generateGrid 8 14 )



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
        [ Attr.class "grid", onClick RefreshGrid ]
        (List.map viewRow grid.rows)


viewRow : Row -> Html msg
viewRow row =
    Html.div
        [ Attr.class "grid--row"
        , Attr.style "height" (cssPercentage row.height)
        ]
        (List.map viewCell row.cells)


cssPercentage : Float -> String
cssPercentage float =
    String.fromFloat float ++ "%"


viewCell : Cell -> Html msg
viewCell cell =
    let
        modifier =
            String.toLower (colorToString cell.color)
    in
    Html.div
        [ Attr.class "grid--cell"
        , Attr.class ("grid--cell__" ++ modifier)
        , Attr.style "width" (cssPercentage cell.width)
        ]
        []


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


randomInt : Generator Int
randomInt =
    Random.int 10 100


type alias RandomRow =
    { height : Int
    , widths : List Int
    , colors : List Color
    }


generateGrid : Int -> Int -> Cmd Msg
generateGrid rows cols =
    let
        heightsGenerator =
            Random.list rows randomInt

        widthsGenerator =
            Random.list cols randomInt

        randomRows =
            Random.pair heightsGenerator widthsGenerator
                |> Random.andThen
                    (\( heights, widths ) ->
                        Random.Extra.combine
                            (List.map
                                (\height ->
                                    Random.map3
                                        RandomRow
                                        (Random.constant height)
                                        (Random.constant widths)
                                        (Random.list cols randomColor)
                                )
                                heights
                            )
                    )

        gridGenerator =
            Random.map buildGrid randomRows
    in
    Random.generate NewGrid gridGenerator


randomColor : Generator Color
randomColor =
    Random.weighted
        ( 10, White )
        [ ( 1, Red )
        , ( 1, Yellow )
        , ( 1, Blue )
        ]


buildGrid : List RandomRow -> Grid
buildGrid randomRows =
    let
        totalHeight =
            List.map .height randomRows
                |> List.sum
    in
    { rows = List.map (buildRow totalHeight) randomRows }


buildRow : Int -> RandomRow -> Row
buildRow totalHeight { height, widths, colors } =
    let
        totalWidth =
            List.sum widths

        toPercentage value total =
            toFloat value * 100 / toFloat total

        result =
            List.map2 Tuple.pair widths colors
                |> List.map
                    (\( width, color ) ->
                        { width = toPercentage width totalWidth
                        , color = color
                        }
                    )
    in
    { height = toPercentage height totalHeight
    , cells = result
    }
