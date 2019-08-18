import java.util.Random;
import java.util.concurrent.locks.ReentrantLock;
import java.util.ArrayDeque;
import java.lang.Integer;


public class fish extends Thread{

    static ReentrantLock salmon;
    static ArrayDeque<Integer> line;

/*
    public class Customer extends Thread{
        public void run(int id){
        
        }
    }
*/

    public static class Monger extends Thread{
        Random randy = new Random();
        public void run(){
            int cc=0;
            while(true){
                salmon.lock();
                if(line.size() !=0){
                    try{
                        //sleep(randy.nextInt(9)+1);
                        //salmon.lock();
                        cc = (line.remove()).intValue();
                        //salmon.unlock();
                        sleep((randy.nextInt(9)+1)*1000);
                        //System.out.print("HEEEEEEEEY");
                    }catch (InterruptedException e){
                        //salmon.unlock();
                        System.out.println("no costumer to service");
                    }
                    System.out.println("serviced costumer:"+cc+" by:"+this.getName());
                }
                salmon.unlock();
            }
        }
    }      

    public void run(){
        Random randy = new Random();
        int i = 0;
        while(true){
            try{
                sleep((randy.nextInt(9)+1)*1000);
                line.add(i);
                //System.out.print("HEEEEEEEEY");
                i++;
            }catch (InterruptedException e){
            }
        }
    }

    public static void main(String[] args) {
        salmon = new ReentrantLock();
        line = new ArrayDeque<Integer>();
        Monger m[] = new Monger[5]; 

        for(int i = 0; i<5; i++){
            m[i] = new Monger();
            m[i].start();
            //Monger().start();//.monger m = new monger yadayada
        }

        fish market = new fish();
        market.start();
    }

}


/*
    a customer will put a number in the que and wait till it is answered then print something
    a monger witll get a number from the que then sleep for a little bit asends a signal to the customer to finish up
    fish creats the lock and the que. spawns 5 mongers and then in diterminetly spawns customers  
*/