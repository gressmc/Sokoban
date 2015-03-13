//
//  main.swift
//  Sokoban
//
//  Created by gressmc on 12/03/15.
//  Copyright (c) 2015 gressmc. All rights reserved.
//

import Foundation
import Darwin

enum Type{
    case Box(String,Bool)
    case Person(String)
    case Border(String)
    case BoxMark(String,Bool)
}
let border = " ◼️"
let floor = " ◻️"

var mapLevel1 = ["XXXXXXXX",
    "X     XX",
    "X0 #  XX",
    "XXXX # X",
    "X      X",
    "X     @X",
    "X 0  X X",
    "XXXXXXXX"]

// Структура комнаты
struct Room {
    // Уровень 1
    static var mapLevel = mapLevel1
    
    static var height : Int {return countElements(Room.mapLevel[0])}
    static var weight : Int {return Room.mapLevel.count}
    
    // Тут мы парсим карту уровеня и забиваем массив изображений
    static func array() -> [String] {
        var field = [String]()
        var tmp = ""
        
        func check(idx:Int, row:String, column:String) -> Point{
            var p = Point(x: 0, y: 0)
            p.x = idx
            p.y = NSString(string:row).rangeOfString(column).location
            return p
        }
        for (idx,row) in enumerate(mapLevel){
            for column in row {
                switch column {
                case "X" : tmp = border
                case "0" : tmp = BoxMark.imageBoxMark
                BoxMark.position = check(idx, row, String(column))
                BoxMark.arrayBoxMark.append([BoxMark.position.x:BoxMark.position.y])
                case "#" : tmp = Box.imageBox
                case "@" : tmp = Person.imagePerson
                Person.position = check(idx, row, String(column))
                default : tmp = floor
                }
                field.append(tmp)
            }
        }
        return field
    }
    
    // Копируем полученный массив в переменную экземпляра комнаты
    var field:[String] = Room.array()
    
    // Рисуем уровень
    func printBorderField(){
        let array = Room.array
        for row in 0..<Room.weight{
            for column in 0..<Room.height{
                print(field[(row * Room.height) + column])
            }
            println()
        }
    }
    // Тут проверяем на столкновение со стеной
    func indexIsValidForRow(row:Int, column:Int) -> Bool{
        return field[(row * Room.height) + column] != border
    }
    
    // Тут проверяем на столкновение с ящиком
    func checkCollision(row:Int, column:Int) -> Bool{
        return field[(row * Room.height) + column] != Box.imageBox
    }
    
    // Тут описываем сабскрипт для визуально более приятного доступа к 'матрице' комнаты в последствии.
    // Можно обойтись и без этого конечно. Тогда вместо обращения room[x, y] - следует создавать массив в массиве и обращаться так room[x][y]
    subscript(row:Int,column:Int) -> String {
        get{
            return field[(row * Room.height) + column]
        }
        set{
            if indexIsValidForRow(row, column: column) {
                field[(row * Room.height) + column] = newValue
            }
        }
    }
}

// Отработка направления движения
func switchDirection(dir: Direction,inout pos:Point){
    
    // Очищаем за собой место.
    func clear(){
        let a = BoxMark.arrayBoxMark.filter{$0 == [pos.x:pos.y]}
        if a.isEmpty{
            room[pos.x, pos.y] = floor
        } else {
            room[pos.x, pos.y] = BoxMark.imageBoxMark
        }
    }
    
    switch dir {
    case .Up : if room.indexIsValidForRow(pos.x-1, column: pos.y) {
        if room.checkCollision(pos.x-1, column: pos.y){
            clear()
            pos.x--
        } else  if room.indexIsValidForRow(pos.x-2, column: pos.y){
            Box.moveBox(dir, room: &room, pos: Point(x: pos.x-1, y: pos.y))
            clear()
            pos.x--
        }
        }
    case .Down : if room.indexIsValidForRow(pos.x+1, column: pos.y) {
        if room.checkCollision(pos.x+1, column: pos.y) {
            clear()
            pos.x++
        }else if room.indexIsValidForRow(pos.x+2, column: pos.y){
            Box.moveBox(dir, room: &room, pos: Point(x: pos.x+1, y: pos.y))
            clear()
            pos.x++
        }
        }
    case .Left : if room.indexIsValidForRow(pos.x, column: pos.y-1) {
        
        if room.checkCollision(pos.x, column: pos.y-1) {
            clear()
            pos.y--
        }else if room.indexIsValidForRow(pos.x, column: pos.y-2){
            Box.moveBox(dir, room: &room, pos: Point(x: pos.x, y: pos.y-1))
            clear()
            pos.y--
        }
        }
    case .Right : if room.indexIsValidForRow(pos.x, column: pos.y+1) {
        if room.checkCollision(pos.x, column: pos.y+1) {
            clear()
            pos.y++
        }else if room.indexIsValidForRow(pos.x, column: pos.y+2){
            Box.moveBox(dir, room: &room, pos: Point(x: pos.x, y: pos.y+1))
            clear()
            pos.y++
        }
        }
    }
}

// Глобальные структуры Point и перечисления Direction
struct Point {
    var x : Int
    var y : Int
    
    mutating func moveByX(x:Int, byY y:Int){
        self.x += x
        self.y += y
    }
}

enum Direction{
    case Up
    case Down
    case Right
    case Left
}

// Единственная структура игрока
struct Person {
    static let imagePerson = " 😄"
    static var position = Point(x: 4, y: 5)
    mutating func movePerson(dir: Direction, inout room: Room){
        switchDirection(dir, &Person.position)
        room[Person.position.x, Person.position.y] = Person.imagePerson
    }
}

// Абстрактнная модель ящика
struct Box {
    static let imageBox = " #️⃣"
    static var position = Point(x: 0, y: 0)
    static func moveBox(dir: Direction, inout room: Room, var pos: Point){
        switchDirection(dir, &pos)
        room[pos.x, pos.y] = Box.imageBox
    }
}

struct BoxMark {
    static let imageBoxMark = " ⭕️"
    static var arrayBoxMark = [[Int:Int]]()
    static var position = Point(x: 0, y: 0)
}

// Создаем комнату и игрока
var room = Room()
var smile = Person()
// Рисуем уровень
system("/usr/bin/clear")
room.printBorderField()

// Ираем )))
func game(){
    func inputText() -> String{
        
        var input = UnsafeMutablePointer<Int8>.null()
        var cap: UInt = 0
        errno = 0 // EOF doesn't set errno, so we need this to distinguish
        
        var len = getline(&input, &cap, stdin)
        if len == -1 {
            if errno == 0 {
                // EOF
                len = 0
            } else {
                "error".withCString() { perror($0) }
                exit(1)
            }
        } else {
            // trim off the trailing newline
            if UInt8(input[len-1]) == UInt8("\n") {
                input[len-1] = 0
            }
        }
        system("/usr/bin/clear")
        return String.fromCString(input)!
    }
    let str = inputText()
    switch str {
    case "U" : smile.movePerson(.Up, room: &room)
    case "D" : smile.movePerson(.Down, room: &room)
    case "L" : smile.movePerson(.Left, room: &room)
    case "R" : smile.movePerson(.Right, room: &room)
    case "E" : exit(1)
    default:break
    }
    let a = room.field.filter{$0 == BoxMark.imageBoxMark}
    
    
    room.printBorderField()
    if a.isEmpty {
        println("YOU WIN")
        println("Press Enter For Next Level")
    }else{
        println("Press (U,D,L,R) + Enter For Move")
    }
    
    if !a.isEmpty {
        game()
    } else {
        Room.mapLevel = ["XXXXXXXXXXXXXXXXXX",
                         "X    XXXXXXXX    X",
                         "X0 #  XXXXXX     X",
                         "XXXX  # XXX    # X",
                         "X       XX      XX",
                         "X                X",
                         "X         0     #X",
                         "X                X",
                         "X    #XXX        X",
                         "X      XXXX      X",
                         "X   X    XXXX    X",
                         "X   X  0  XX     X",
                         "X   XX    X      X",
                         "X                X",
                         "X                X",
                         "X 0  X  XXX      X",
                         "X    X @XX0    #0X",
                         "XXXXXXXXXXXXXXXXXX"]
        room.field.removeAll()
        room = Room()
        game()
    }
}
game()
