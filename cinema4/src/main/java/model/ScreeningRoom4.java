package model;

import java.util.ArrayList;

// capacity là thuộc tính dẫn xuất: số ghế của phòng
public class ScreeningRoom4 {
    private int id;
    private String roomCode;
    private String name;
    private int capacity;
    private String roomType;
    private String description;
    private ArrayList<Seat4> listSeat;

    public ScreeningRoom4() {
        super();
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getRoomCode() {
        return roomCode;
    }

    public void setRoomCode(String roomCode) {
        this.roomCode = roomCode;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getRoomType() {
        return roomType;
    }

    public void setRoomType(String roomType) {
        this.roomType = roomType;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public ArrayList<Seat4> getListSeat() {
        return listSeat;
    }

    public void setListSeat(ArrayList<Seat4> listSeat) {
        this.listSeat = listSeat;
    }
}
