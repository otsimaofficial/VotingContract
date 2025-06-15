## 🗳️ Nigeria Election Voting Smart Contract

A robust and secure smart contract built in Solidity to simulate the Nigerian presidential election process. This system enforces voter validation (age, location, card expiry), prevents double voting, and supports gender/location-based vote statistics. It also uses role-based access control without external dependencies like OpenZeppelin.

---

### 📂 Folder Structure

```
.
├── src/
│   └── NigeriaElection.sol       # Main Voting Contract
│   └── AdminRole.sol             # Role-based access control module
├── test/
│   └── NigeriaElection.t.sol     # Foundry test cases
├── script/
│   └── Deploy.s.sol              # Deployment script (optional)
├── README.md                     # You're here
```

---

### 🚀 Features

* ✅ Role-based access: Owner & Admins
* ✅ Age restriction (≥ 18)
* ✅ Voter card expiration check
* ✅ Prevents double voting
* ✅ One vote per voter
* ✅ Gender and location-based statistics
* ✅ Structs, enums, mappings, arrays, modifiers, custom errors, events

---

### 🧱 Built With

* **Solidity v0.8.24**
* **Foundry (for testing)**

---

### 🛠️ How to Use

#### 1. Clone and install Foundry

```bash
git clone <repo-url>
cd <project-folder>
forge install
```

#### 2. Compile

```bash
forge build
```

#### 3. Run Tests

```bash
forge test -vv
```

---

### 📘 Contract Summary

#### 👤 Roles

* **Owner**: Can add/remove admins and candidates.
* **Admin**: Can register and validate voters.
* **Voter**: Can vote once during election period if valid.

#### 📋 Structs

```solidity
struct Voter {
    string name;
    uint8 age;
    Gender gender;
    string location;
    string voterId;
    uint256 cardExpiry;
    bool hasVoted;
    address wallet;
}

struct Candidate {
    string name;
    uint256 voteCount;
}
```

#### 📊 Statistics

* `getGenderStats()` – Returns total male and female voters.
* `getVotesByLocation(string)` – Returns how many voters are from a given location.
* `getResult()` – Candidate vote counts.

---

### 🔐 Security Measures

* Only eligible voters (≥ 18, valid card) can vote.
* Only owner can modify critical settings.
* Custom errors save gas and improve clarity.

---

### 📤 Events

* `VoterRegistered`
* `VoteCast`
* `AdminAdded`
* `AdminRemoved`
* `CandidateAdded`

---

### 💡 Future Improvements

* Election phases (`NotStarted`, `Active`, `Ended`)
* Pause/resume voting
* Storing winner post-election
* On-chain location analytics
* Wallet-voter ID binding enforcement

---

### 👨‍💻 Author

**Ogbu Emmanuel Otsima**
Solidity Smart Contract Developer

> Let's connect on [LinkedIn](#) | [GitHub](#) | [Twitter](#)

---

### 📄 License

MIT

---

Would you like a Markdown badge header (`[![Tests Passing](...)]`) or demo video integration too?
