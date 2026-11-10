package unittest;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.time.LocalDate;

import org.junit.After;
import org.junit.Test;

import dao.CustomerDAO4;
import dao.MemberDAO4;
import model.Customer4;
import model.Member4;
import model.Saler4;

public class RegisterMemberDAOTest {

    @After
    public void cleanUp() throws Exception {
        TestDB.execute(
                "DELETE c FROM tblCustomer4 c JOIN tblMember4 m ON m.id = c.memberId WHERE m.username = 'test.junit'",
                "DELETE FROM tblMember4 WHERE username = 'test.junit'",
                "ALTER TABLE tblMember4 AUTO_INCREMENT = 1235");
    }

    private Customer4 newCustomer() {
        Customer4 c = new Customer4();
        c.setFullName("Phạm Thị D");
        c.setDateOfBirth(LocalDate.of(2001, 2, 3));
        c.setGender("Nữ");
        c.setPhone("0987000111");
        c.setEmail("test.junit@gmail.com");
        c.setUsername("test.junit");
        c.setPassword("123456");
        return c;
    }

    @Test
    public void checkDuplicateInfoFindsUsedPhone() {
        Customer4 c = newCustomer();
        c.setPhone("0912345678");
        assertTrue(new CustomerDAO4().checkDuplicateInfo(c));
    }

    @Test
    public void saveCustomerSetsIdCodeAndDate() {
        CustomerDAO4 dao = new CustomerDAO4();
        Customer4 c = newCustomer();
        assertFalse(dao.checkDuplicateInfo(c));
        assertTrue(dao.saveCustomer(c));
        assertEquals(String.format("KH%07d", c.getId()), c.getCustomerCode());
        assertEquals(LocalDate.now(), c.getRegisterDate());
        assertTrue(dao.checkDuplicateInfo(c));
        Member4 login = new Member4() {
        };
        login.setUsername("test.junit");
        login.setPassword("123456");
        assertTrue(new MemberDAO4().checkLogin(login) instanceof Customer4);
    }

    @Test
    public void checkLoginReturnsSalerSubclass() {
        Member4 m = new Member4() {
        };
        m.setUsername("banve.b");
        m.setPassword("123456");
        Member4 result = new MemberDAO4().checkLogin(m);
        assertNotNull(result);
        assertTrue(result instanceof Saler4);
        assertEquals("Trần Thị B", result.getFullName());
        assertEquals("Quầy số 2", ((Saler4) result).getCounter());
    }

    @Test
    public void checkLoginWrongPasswordReturnsNull() {
        Member4 m = new Member4() {
        };
        m.setUsername("banve.b");
        m.setPassword("sai");
        assertNull(new MemberDAO4().checkLogin(m));
    }
}
