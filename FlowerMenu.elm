module Main exposing (..)

{-| Recreating the menu found here: https://github.com/nashvail/ReactPathMenu
Make using:
   elm-make FlowerMenu.elm --output elm.js
   open index.html


-}

import Time exposing (second, Time)
import Html.App
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import AnimationFrame
import Style
import Style.Properties exposing (..)
import Animation


type alias Model =
    { submenus : List Submenu
    , open : Bool
    , message : Maybe String
    , sheet : Animation.StyleSheet
    }


type alias Submenu =
    { icon : String
    }


type Msg
    = Toggle
    | ShowMessage String
    | Animate Time


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Toggle ->
            if model.open then
                ( { model
                    | open = False
                    , sheet = Animation.update Animation.Close model.sheet
                  }
                , Cmd.none
                )
            else
                ( { model
                    | open = True
                    , sheet = Animation.update Animation.Open model.sheet
                  }
                , Cmd.none
                )

        ShowMessage str ->
            ( { model
                | message = Just str
                , sheet = Animation.update Animation.ShowMessage model.sheet
              }
            , Cmd.none
            )

        Animate time ->
            ( { model | sheet = Animation.tick time model.sheet }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    let
        icon =
            i
                [ class "fa fa-close fa-3x"
                , style (Animation.render model.sheet Animation.Menu)
                ]
                []

        message =
            case model.message of
                Nothing ->
                    div [] []

                Just msg ->
                    div
                        [ class "message"
                        , style (Animation.render model.sheet Animation.Message)
                        ]
                        [ text msg ]

        submenus =
            List.indexedMap (viewSubmenu model.sheet) model.submenus
    in
        div
            [ class "main-button"
            , onClick Toggle
            ]
            (icon :: message :: submenus)


viewSubmenu : Animation.StyleSheet -> Int -> Submenu -> Html Msg
viewSubmenu sheet id submenu =
    div
        [ class "child-button"
        , style (Animation.render sheet (Animation.Submenu id))
        , onClick (ShowMessage submenu.icon)
        ]
        [ i [ class ("fa  fa-lg fa-" ++ submenu.icon) ] []
        ]


icons : List String
icons =
    List.take 5 [ "pencil", "at", "camera", "bell", "comment", "bolt", "ban", "code" ]


init =
    ( { open = False
      , submenus =
            List.map (\icon -> { icon = icon }) icons
      , message = Nothing
      , sheet = Animation.sheet (List.length icons)
      }
    , Cmd.none
    )


main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = (\_ -> AnimationFrame.times Animate)
        }
